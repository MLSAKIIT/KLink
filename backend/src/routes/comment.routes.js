const express = require('express');
const router = express.Router();
const commentController = require('../controllers/comment.controller');
const { authenticateUser } = require('../middleware/auth.middleware');
const { validate, schemas } = require('../middleware/validation.middleware');
const { apiLimiter } = require('../middleware/ratelimit.middleware');

// Get comments for a post
router.get('/post/:postId', apiLimiter, commentController.getCommentsByPost);

// Create comment
router.post('/', authenticateUser, apiLimiter, validate(schemas.createComment), commentController.createComment);

// Delete comment
router.delete('/:id', authenticateUser, apiLimiter, commentController.deleteComment);

module.exports = router;
