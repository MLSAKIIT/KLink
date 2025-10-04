const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { validate, schemas } = require('../middleware/validation.middleware');
const { authLimiter } = require('../middleware/ratelimit.middleware');
const { authenticateUser } = require('../middleware/auth.middleware');

// Apply rate limiting to all auth routes
router.use(authLimiter);

// Auth routes
router.post('/signup', validate(schemas.signup), authController.signup);
router.post('/login', validate(schemas.login), authController.login);
router.post('/google', authController.googleAuth);
router.post('/logout', authenticateUser, authController.logout);
router.get('/me', authenticateUser, authController.getCurrentUser);
router.put('/profile', authenticateUser, validate(schemas.updateProfile), authController.updateProfile);
router.get('/users/:id', authenticateUser, authController.getUserById);

module.exports = router;
