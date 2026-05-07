const crypto = require('crypto');
const Otp = require('../models/Otp');
const ApiError = require('../utils/ApiError');
const { sendOtpSms } = require('./smsService');
const { sendOtpEmail } = require('./emailService');

const OTP_LEN = parseInt(process.env.OTP_LENGTH, 10) || 6;
const OTP_TTL_MIN = parseInt(process.env.OTP_EXPIRES_IN_MINUTES, 10) || 5;
const MAX_ATTEMPTS = parseInt(process.env.OTP_MAX_ATTEMPTS, 10) || 5;
const COOLDOWN_SEC = parseInt(process.env.OTP_RESEND_COOLDOWN_SECONDS, 10) || 60;

function generateNumericCode(len = OTP_LEN) {
  const max = 10 ** len;
  const num = crypto.randomInt(0, max);
  return num.toString().padStart(len, '0');
}

async function issueOtp({ identifier, channel, purpose, ip, userAgent }) {
  const recent = await Otp.findOne({ identifier, channel, purpose })
    .sort({ createdAt: -1 })
    .lean();
  if (recent) {
    const ageSec = (Date.now() - new Date(recent.createdAt).getTime()) / 1000;
    if (ageSec < COOLDOWN_SEC) {
      throw new ApiError(429, `Please wait ${Math.ceil(COOLDOWN_SEC - ageSec)}s before requesting another code`);
    }
  }

  await Otp.deleteMany({ identifier, channel, purpose, consumed: false });

  const code = generateNumericCode();
  const codeHash = await Otp.hashCode(code);
  const otp = await Otp.create({
    identifier,
    channel,
    purpose,
    codeHash,
    expiresAt: new Date(Date.now() + OTP_TTL_MIN * 60 * 1000),
    ip,
    userAgent,
  });

  if (channel === 'sms') await sendOtpSms(identifier, code);
  else if (channel === 'email') await sendOtpEmail(identifier, code);

  return { id: otp._id.toString(), expiresAt: otp.expiresAt };
}

async function verifyOtp({ identifier, channel, purpose, code }) {
  const otp = await Otp.findOne({ identifier, channel, purpose, consumed: false }).sort({ createdAt: -1 });
  if (!otp) throw new ApiError(400, 'No active verification code. Please request a new one.');
  if (otp.expiresAt < new Date()) throw new ApiError(400, 'Verification code expired');
  if (otp.attempts >= MAX_ATTEMPTS) {
    otp.consumed = true;
    await otp.save();
    throw new ApiError(429, 'Too many failed attempts. Please request a new code.');
  }

  const ok = await otp.compare(code);
  if (!ok) {
    otp.attempts += 1;
    await otp.save();
    throw new ApiError(400, 'Invalid verification code');
  }

  otp.consumed = true;
  await otp.save();
  return true;
}

module.exports = { issueOtp, verifyOtp };
