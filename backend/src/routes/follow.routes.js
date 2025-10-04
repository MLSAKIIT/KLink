const express = require('express');
const router = express.Router();
const followController = require('../controllers/follow.controller');
const { authenticateUser } = require('../middleware/auth.middleware');
const { apiLimiter } = require('../middleware/ratelimit.middleware');

// Follow user
router.post('/:userId', authenticateUser, apiLimiter, followController.followUser);

// Unfollow user
router.delete('/:userId', authenticateUser, apiLimiter, followController.unfollowUser);

// Get user's followers
router.get('/followers/:userId', apiLimiter, followController.getFollowers);

// Get users that user follows
router.get('/following/:userId', apiLimiter, followController.getFollowing);

// Check if following
router.get('/check/:userId', authenticateUser, apiLimiter, followController.checkFollowing);

module.exports = router;
