const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const { authLimiter, otpLimiter, otpVerifyLimiter } = require('../middleware/rateLimit');
const { protect } = require('../middleware/auth');
const c = require('../controllers/authController');

const router = express.Router();

const passwordRule = body('password')
  .isLength({ min: 8 })
  .withMessage('Password must be at least 8 characters')
  .matches(/[A-Z]/).withMessage('Password must contain an uppercase letter')
  .matches(/[a-z]/).withMessage('Password must contain a lowercase letter')
  .matches(/\d/).withMessage('Password must contain a digit');

router.post(
  '/signup/email',
  authLimiter,
  [
    body('name').trim().isLength({ min: 2, max: 100 }),
    body('email').isEmail().normalizeEmail(),
    passwordRule,
  ],
  validate,
  c.signupEmail
);

router.post(
  '/signup/phone',
  otpLimiter,
  [
    body('name').trim().isLength({ min: 2, max: 100 }),
    body('phone').matches(/^\+[1-9]\d{6,14}$/).withMessage('Phone must be E.164 (e.g. +14155551234)'),
  ],
  validate,
  c.signupPhone
);

router.post(
  '/verify/phone',
  otpVerifyLimiter,
  [
    body('phone').matches(/^\+[1-9]\d{6,14}$/),
    body('code').isLength({ min: 4, max: 8 }).isNumeric(),
  ],
  validate,
  c.verifyPhoneOtp
);

router.post(
  '/verify/email',
  [body('token').isString().isLength({ min: 10 })],
  validate,
  c.verifyEmail
);

router.post(
  '/verify/email/resend',
  otpLimiter,
  [body('email').isEmail().normalizeEmail()],
  validate,
  c.resendEmailVerification
);

router.post(
  '/login/email',
  authLimiter,
  [body('email').isEmail().normalizeEmail(), body('password').notEmpty()],
  validate,
  c.loginEmail
);

router.post(
  '/login/phone/request',
  otpLimiter,
  [body('phone').matches(/^\+[1-9]\d{6,14}$/)],
  validate,
  c.requestPhoneLoginOtp
);

router.post(
  '/login/phone/verify',
  otpVerifyLimiter,
  [
    body('phone').matches(/^\+[1-9]\d{6,14}$/),
    body('code').isLength({ min: 4, max: 8 }).isNumeric(),
  ],
  validate,
  c.loginPhone
);

router.post(
  '/forgot-password',
  authLimiter,
  [body('email').isEmail().normalizeEmail()],
  validate,
  c.forgotPassword
);

router.post(
  '/reset-password',
  authLimiter,
  [body('token').isString().isLength({ min: 10 }), passwordRule],
  validate,
  c.resetPassword
);

router.post('/refresh', c.refreshToken);
router.post('/logout', c.logout);
router.get('/me', protect, c.me);
router.post(
  '/change-password',
  protect,
  [body('currentPassword').notEmpty(), body('newPassword').isLength({ min: 8 })],
  validate,
  c.changePassword
);

module.exports = router;
