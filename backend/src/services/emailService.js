const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');

let transporter;

function getTransporter() {
  if (transporter) return transporter;

  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT, 10) || 587,
    secure: String(process.env.SMTP_SECURE) === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  if (process.env.NODE_ENV !== 'production') {
    transporter.verify().then(
      () => logger.info('SMTP transporter ready'),
      (err) => logger.warn('SMTP verify failed:', err.message)
    );
  }

  return transporter;
}

function loadTemplate(name, vars = {}) {
  const file = path.join(__dirname, '..', 'templates', 'email', `${name}.html`);
  let html = fs.readFileSync(file, 'utf8');
  for (const [k, v] of Object.entries(vars)) {
    html = html.replaceAll(`{{${k}}}`, String(v ?? ''));
  }
  return html;
}

async function sendMail({ to, subject, html, text }) {
  const from = `"${process.env.EMAIL_FROM_NAME || 'App'}" <${process.env.EMAIL_FROM_ADDRESS || process.env.SMTP_USER}>`;
  const info = await getTransporter().sendMail({ from, to, subject, html, text });
  logger.info(`Email sent to ${to}: ${info.messageId}`);
  return info;
}

async function sendVerificationEmail(user, token) {
  const url = `${process.env.CLIENT_URL}/verify-email.html?token=${token}&email=${encodeURIComponent(user.email)}`;
  const html = loadTemplate('verification', {
    name: user.name,
    verifyUrl: url,
    appName: process.env.EMAIL_FROM_NAME || 'Company App',
    expiresIn: '24 hours',
  });
  return sendMail({
    to: user.email,
    subject: 'Verify your email address',
    html,
    text: `Hi ${user.name}, verify your email: ${url}`,
  });
}

async function sendWelcomeEmail(user) {
  const html = loadTemplate('welcome', {
    name: user.name,
    appName: process.env.EMAIL_FROM_NAME || 'Company App',
    loginUrl: `${process.env.CLIENT_URL}/login.html`,
  });
  return sendMail({
    to: user.email,
    subject: `Welcome to ${process.env.EMAIL_FROM_NAME || 'Company App'}!`,
    html,
    text: `Welcome aboard, ${user.name}!`,
  });
}

async function sendPasswordResetEmail(user, token) {
  const url = `${process.env.CLIENT_URL}/reset-password.html?token=${token}&email=${encodeURIComponent(user.email)}`;
  const html = loadTemplate('reset-password', {
    name: user.name,
    resetUrl: url,
    appName: process.env.EMAIL_FROM_NAME || 'Company App',
    expiresIn: '1 hour',
  });
  return sendMail({
    to: user.email,
    subject: 'Password reset request',
    html,
    text: `Reset your password: ${url}`,
  });
}

async function sendOtpEmail(email, code) {
  const html = loadTemplate('otp', {
    code,
    appName: process.env.EMAIL_FROM_NAME || 'Company App',
    expiresIn: `${process.env.OTP_EXPIRES_IN_MINUTES || 5} minutes`,
  });
  return sendMail({
    to: email,
    subject: `Your verification code: ${code}`,
    html,
    text: `Your verification code is ${code}. It expires in ${process.env.OTP_EXPIRES_IN_MINUTES || 5} minutes.`,
  });
}

module.exports = {
  sendMail,
  sendVerificationEmail,
  sendWelcomeEmail,
  sendPasswordResetEmail,
  sendOtpEmail,
};
