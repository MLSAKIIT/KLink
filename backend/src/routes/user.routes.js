const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticateUser } = require('../middleware/auth.middleware');
const { apiLimiter } = require('../middleware/ratelimit.middleware');

router.get('/search', apiLimiter, authController.searchUsers);
router.get('/:id', authenticateUser, authController.getUserById);

module.exports = router;
