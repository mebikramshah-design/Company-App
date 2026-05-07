const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const otpSchema = new mongoose.Schema(
  {
    identifier: { type: String, required: true, index: true },
    channel: { type: String, enum: ['sms', 'email'], required: true },
    purpose: {
      type: String,
      enum: ['signup', 'login', 'verify_phone', 'verify_email', 'reset_password'],
      required: true,
    },
    codeHash: { type: String, required: true },
    expiresAt: { type: Date, required: true, index: { expires: 0 } },
    attempts: { type: Number, default: 0 },
    consumed: { type: Boolean, default: false },
    ip: String,
    userAgent: String,
  },
  { timestamps: true }
);

otpSchema.statics.hashCode = async function (code) {
  return bcrypt.hash(code, 10);
};

otpSchema.methods.compare = function (code) {
  return bcrypt.compare(code, this.codeHash);
};

module.exports = mongoose.model('Otp', otpSchema);
