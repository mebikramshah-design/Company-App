const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const asyncHandler = require('../utils/asyncHandler');

function extractToken(req) {
  const header = req.headers.authorization;
  if (header && header.startsWith('Bearer ')) return header.slice(7);
  if (req.cookies && req.cookies.access_token) return req.cookies.access_token;
  return null;
}

const protect = asyncHandler(async (req, res, next) => {
  const token = extractToken(req);
  if (!token) throw new ApiError(401, 'Authentication required');

  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  const user = await User.findById(decoded.sub).select('+passwordChangedAt');
  if (!user) throw new ApiError(401, 'User no longer exists');
  if (!user.isActive) throw new ApiError(403, 'Account is deactivated');
  if (user.changedPasswordAfter(decoded.iat)) {
    throw new ApiError(401, 'Password changed recently. Please log in again.');
  }

  req.user = user;
  req.token = token;
  next();
});

const restrictTo = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return next(new ApiError(403, 'You do not have permission to perform this action'));
  }
  next();
};

const requireVerified = (req, res, next) => {
  if (!req.user.isEmailVerified && !req.user.isPhoneVerified) {
    return next(new ApiError(403, 'Please verify your email or phone first'));
  }
  next();
};

module.exports = { protect, restrictTo, requireVerified };
