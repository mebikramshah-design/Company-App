const crypto = require('crypto');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');
const {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  setAuthCookies,
  clearAuthCookies,
} = require('../services/tokenService');
const {
  sendVerificationEmail,
  sendWelcomeEmail,
  sendPasswordResetEmail,
} = require('../services/emailService');
const { issueOtp, verifyOtp } = require('../services/otpService');
const logger = require('../utils/logger');

function authResponse(res, user, statusCode = 200, message = 'OK') {
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  setAuthCookies(res, { accessToken, refreshToken });
  res.status(statusCode).json({
    success: true,
    message,
    data: { user, accessToken, refreshToken },
  });
}

exports.signupEmail = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  const existing = await User.findOne({ email });
  if (existing) throw new ApiError(409, 'Email already registered');

  const user = new User({ name, email, password });
  const rawToken = user.createEmailVerificationToken();
  await user.save();

  try {
    await sendVerificationEmail(user, rawToken);
  } catch (err) {
    logger.error('Failed to send verification email:', err);
  }

  res.status(201).json({
    success: true,
    message: 'Account created. Please check your email to verify your account.',
    data: { userId: user._id, email: user.email },
  });
});

exports.signupPhone = asyncHandler(async (req, res) => {
  const { name, phone } = req.body;

  let user = await User.findOne({ phone });
  if (user && user.isPhoneVerified) throw new ApiError(409, 'Phone already registered');
  if (!user) user = await User.create({ name, phone });

  const result = await issueOtp({
    identifier: phone,
    channel: 'sms',
    purpose: 'signup',
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });

  res.status(201).json({
    success: true,
    message: 'OTP sent to your phone',
    data: { userId: user._id, phone, expiresAt: result.expiresAt },
  });
});

exports.verifyPhoneOtp = asyncHandler(async (req, res) => {
  const { phone, code } = req.body;

  await verifyOtp({ identifier: phone, channel: 'sms', purpose: 'signup', code });

  const user = await User.findOne({ phone });
  if (!user) throw new ApiError(404, 'User not found');

  user.isPhoneVerified = true;
  user.lastLoginAt = new Date();
  user.lastLoginIP = req.ip;
  await user.save();

  authResponse(res, user, 200, 'Phone verified successfully');
});

exports.verifyEmail = asyncHandler(async (req, res) => {
  const { token } = req.body;
  if (!token) throw new ApiError(400, 'Verification token required');

  const hashed = crypto.createHash('sha256').update(token).digest('hex');
  const user = await User.findOne({
    emailVerificationToken: hashed,
    emailVerificationExpires: { $gt: Date.now() },
  }).select('+emailVerificationToken +emailVerificationExpires');

  if (!user) throw new ApiError(400, 'Invalid or expired verification link');

  user.isEmailVerified = true;
  user.emailVerificationToken = undefined;
  user.emailVerificationExpires = undefined;
  await user.save();

  sendWelcomeEmail(user).catch((err) => logger.error('Welcome email failed:', err));

  authResponse(res, user, 200, 'Email verified successfully');
});

exports.resendEmailVerification = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });
  if (!user) throw new ApiError(404, 'No account with that email');
  if (user.isEmailVerified) throw new ApiError(400, 'Email already verified');

  const rawToken = user.createEmailVerificationToken();
  await user.save({ validateBeforeSave: false });
  await sendVerificationEmail(user, rawToken);

  res.json({ success: true, message: 'Verification email sent' });
});

exports.loginEmail = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password +failedLoginAttempts +lockUntil');
  if (!user) throw new ApiError(401, 'Invalid credentials');
  if (user.isLocked) throw new ApiError(423, 'Account is temporarily locked. Try again later.');
  if (!user.password) throw new ApiError(400, 'This account uses phone login. Please sign in with phone.');

  const ok = await user.comparePassword(password);
  if (!ok) {
    await user.registerFailedLogin();
    throw new ApiError(401, 'Invalid credentials');
  }

  if (!user.isEmailVerified) throw new ApiError(403, 'Please verify your email before logging in');

  await user.resetLoginAttempts();
  user.lastLoginAt = new Date();
  user.lastLoginIP = req.ip;
  await user.save({ validateBeforeSave: false });

  authResponse(res, user, 200, 'Login successful');
});

exports.requestPhoneLoginOtp = asyncHandler(async (req, res) => {
  const { phone } = req.body;
  const user = await User.findOne({ phone });
  if (!user) throw new ApiError(404, 'No account with that phone');

  const result = await issueOtp({
    identifier: phone,
    channel: 'sms',
    purpose: 'login',
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });

  res.json({ success: true, message: 'OTP sent', data: { expiresAt: result.expiresAt } });
});

exports.loginPhone = asyncHandler(async (req, res) => {
  const { phone, code } = req.body;
  await verifyOtp({ identifier: phone, channel: 'sms', purpose: 'login', code });

  const user = await User.findOne({ phone });
  if (!user) throw new ApiError(404, 'User not found');

  user.isPhoneVerified = true;
  user.lastLoginAt = new Date();
  user.lastLoginIP = req.ip;
  await user.save({ validateBeforeSave: false });

  authResponse(res, user, 200, 'Login successful');
});

exports.forgotPassword = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });

  if (user) {
    const rawToken = user.createPasswordResetToken();
    await user.save({ validateBeforeSave: false });
    try {
      await sendPasswordResetEmail(user, rawToken);
    } catch (err) {
      user.passwordResetToken = undefined;
      user.passwordResetExpires = undefined;
      await user.save({ validateBeforeSave: false });
      throw new ApiError(500, 'Failed to send password reset email');
    }
  }

  res.json({
    success: true,
    message: 'If that email is registered, a reset link has been sent.',
  });
});

exports.resetPassword = asyncHandler(async (req, res) => {
  const { token, password } = req.body;
  const hashed = crypto.createHash('sha256').update(token).digest('hex');

  const user = await User.findOne({
    passwordResetToken: hashed,
    passwordResetExpires: { $gt: Date.now() },
  }).select('+passwordResetToken +passwordResetExpires');

  if (!user) throw new ApiError(400, 'Invalid or expired reset token');

  user.password = password;
  user.passwordResetToken = undefined;
  user.passwordResetExpires = undefined;
  await user.save();

  authResponse(res, user, 200, 'Password reset successful');
});

exports.refreshToken = asyncHandler(async (req, res) => {
  const token =
    (req.cookies && req.cookies.refresh_token) || req.body.refreshToken || req.headers['x-refresh-token'];
  if (!token) throw new ApiError(401, 'Refresh token required');

  const decoded = verifyRefreshToken(token);
  const user = await User.findById(decoded.sub);
  if (!user || !user.isActive) throw new ApiError(401, 'Invalid refresh token');

  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  setAuthCookies(res, { accessToken, refreshToken });

  res.json({ success: true, data: { accessToken, refreshToken } });
});

exports.logout = asyncHandler(async (req, res) => {
  clearAuthCookies(res);
  res.json({ success: true, message: 'Logged out' });
});

exports.me = asyncHandler(async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
});

exports.changePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const user = await User.findById(req.user._id).select('+password');
  if (!user.password) throw new ApiError(400, 'No password set on account');
  const ok = await user.comparePassword(currentPassword);
  if (!ok) throw new ApiError(401, 'Current password is incorrect');
  user.password = newPassword;
  await user.save();
  authResponse(res, user, 200, 'Password changed');
});
