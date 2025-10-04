const express = require('express');
const router = express.Router();
const followController = require('../controllers/follow.controller');
const { authenticateUser } = require('../middleware/auth.middleware');
const { apiLimiter } = require('../middleware/ratelimit.middleware');

router.post('/:userId', authenticateUser, apiLimiter, followController.followUser);

router.delete('/:userId', authenticateUser, apiLimiter, followController.unfollowUser);

router.get('/followers/:userId', apiLimiter, followController.getFollowers);

router.get('/following/:userId', apiLimiter, followController.getFollowing);

router.get('/check/:userId', authenticateUser, apiLimiter, followController.checkFollowing);

module.exports = router;
