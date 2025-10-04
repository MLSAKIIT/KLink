const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticateUser } = require('../middleware/auth.middleware');

router.get('/:id', authenticateUser, authController.getUserById);

module.exports = router;
