const express = require('express');
const router = express.Router();
const postController = require('../controllers/post.controller');
const { authenticateUser, optionalAuth } = require('../middleware/auth.middleware');
const { validate, schemas } = require('../middleware/validation.middleware');
const { apiLimiter, createLimiter } = require('../middleware/ratelimit.middleware');
const { upload } = require('../middleware/upload.middleware');

router.get('/', optionalAuth, apiLimiter, postController.getAllPosts);

router.get('/following/posts', authenticateUser, apiLimiter, postController.getFollowingPosts);

router.get('/:id', optionalAuth, apiLimiter, postController.getPostById);

router.get('/user/:userId', optionalAuth, apiLimiter, postController.getUserPosts);

router.post('/upload-image', authenticateUser, createLimiter, upload.single('image'), postController.uploadImage);

router.post('/', authenticateUser, createLimiter, validate(schemas.createPost), postController.createPost);

router.put('/:id', authenticateUser, apiLimiter, validate(schemas.updatePost), postController.updatePost);

router.delete('/:id', authenticateUser, apiLimiter, postController.deletePost);

router.post('/:id/like', authenticateUser, apiLimiter, postController.likePost);
router.delete('/:id/like', authenticateUser, apiLimiter, postController.unlikePost);

module.exports = router;
