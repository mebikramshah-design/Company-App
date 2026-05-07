const express = require('express');
const { body } = require('express-validator');
const validate = require('../middleware/validate');
const { protect } = require('../middleware/auth');
const c = require('../controllers/userController');

const router = express.Router();

router.use(protect);

router.get('/me', c.getProfile);
router.patch('/me', [body('name').optional().trim().isLength({ min: 2, max: 100 })], validate, c.updateProfile);
router.delete('/me', c.deleteAccount);

module.exports = router;
