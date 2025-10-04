const Joi = require('joi');

/**
 * Validation middleware factory
 */
const validate = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body, { abortEarly: false });

        if (error) {
            const errors = error.details.map(detail => ({
                field: detail.path.join('.'),
                message: detail.message
            }));

            return res.status(400).json({
                error: 'Validation failed',
                details: errors
            });
        }

        next();
    };
};

// Validation schemas
const schemas = {
    signup: Joi.object({
        email: Joi.string().email().required(),
        password: Joi.string().min(6).required(),
        fullName: Joi.string().min(2).max(100).required(),
        username: Joi.string().min(3).max(30).alphanum().required()
    }),

    login: Joi.object({
        email: Joi.string().email().required(),
        password: Joi.string().required()
    }),

    createPost: Joi.object({
        content: Joi.string().min(1).max(5000).required(),
        imageUrl: Joi.string().uri().allow('', null)
    }),

    updatePost: Joi.object({
        content: Joi.string().min(1).max(5000),
        imageUrl: Joi.string().uri().allow('', null)
    }).min(1),

    createComment: Joi.object({
        postId: Joi.string().uuid().required(),
        content: Joi.string().min(1).max(1000).required()
    }),

    updateProfile: Joi.object({
        username: Joi.string().min(3).max(30).alphanum(),
        fullName: Joi.string().min(2).max(100),
        bio: Joi.string().max(500).allow('', null),
        location: Joi.string().max(100).allow('', null),
        website: Joi.string().uri().allow('', null),
        avatarUrl: Joi.string().uri().allow('', null),
        coverUrl: Joi.string().uri().allow('', null)
    }).min(1)
};

module.exports = { validate, schemas };
