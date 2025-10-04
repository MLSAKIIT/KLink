const express = require('express');
const router = express.Router();
const postController = require('../controllers/post.controller');
const { authenticateUser, optionalAuth } = require('../middleware/auth.middleware');
const { validate, schemas } = require('../middleware/validation.middleware');
const { apiLimiter, createLimiter } = require('../middleware/ratelimit.middleware');

// Get all posts (feed) - public with optional auth
router.get('/', optionalAuth, apiLimiter, postController.getAllPosts);

// Get single post - public with optional auth
router.get('/:id', optionalAuth, apiLimiter, postController.getPostById);

// Get user's posts - public
router.get('/user/:userId', optionalAuth, apiLimiter, postController.getUserPosts);

// Create post - requires auth
router.post('/', authenticateUser, createLimiter, validate(schemas.createPost), postController.createPost);

// Update post - requires auth
router.put('/:id', authenticateUser, apiLimiter, validate(schemas.updatePost), postController.updatePost);

// Delete post - requires auth
router.delete('/:id', authenticateUser, apiLimiter, postController.deletePost);

// Like/unlike post
router.post('/:id/like', authenticateUser, apiLimiter, postController.likePost);
router.delete('/:id/like', authenticateUser, apiLimiter, postController.unlikePost);

module.exports = router;
