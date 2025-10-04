const express = require('express');
const router = express.Router();
const commentController = require('../controllers/comment.controller');
const { authenticateUser } = require('../middleware/auth.middleware');
const { validate, schemas } = require('../middleware/validation.middleware');
const { apiLimiter } = require('../middleware/ratelimit.middleware');

router.get('/post/:postId', apiLimiter, commentController.getCommentsByPost);

router.post('/', authenticateUser, apiLimiter, validate(schemas.createComment), commentController.createComment);

router.delete('/:id', authenticateUser, apiLimiter, commentController.deleteComment);

module.exports = router;
