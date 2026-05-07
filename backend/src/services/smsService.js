const logger = require('../utils/logger');

let twilioClient;

function getClient() {
  if (twilioClient) return twilioClient;
  const sid = process.env.TWILIO_ACCOUNT_SID;
  const token = process.env.TWILIO_AUTH_TOKEN;
  if (!sid || !token) {
    logger.warn('Twilio credentials missing — SMS will be logged only');
    return null;
  }
  twilioClient = require('twilio')(sid, token);
  return twilioClient;
}

async function sendSms(to, body) {
  const client = getClient();
  if (!client) {
    logger.info(`[DEV-SMS] -> ${to}: ${body}`);
    return { sid: 'dev-mock', status: 'logged' };
  }
  const msg = await client.messages.create({
    to,
    from: process.env.TWILIO_PHONE_NUMBER,
    body,
  });
  logger.info(`SMS sent to ${to}: ${msg.sid}`);
  return msg;
}

async function sendOtpSms(phone, code) {
  const appName = process.env.EMAIL_FROM_NAME || 'Company App';
  const expires = process.env.OTP_EXPIRES_IN_MINUTES || 5;
  return sendSms(phone, `${appName}: Your verification code is ${code}. Expires in ${expires} minutes. Do not share.`);
}

module.exports = { sendSms, sendOtpSms };
