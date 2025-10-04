const prisma = require('../config/prisma');

const getCommentsByPost = async (req, res) => {
    try {
        const { postId } = req.params;
        const { limit = 50, offset = 0 } = req.query;

        const comments = await prisma.comment.findMany({
            where: { postId },
            take: parseInt(limit),
            skip: parseInt(offset),
            orderBy: {
                createdAt: 'asc'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                }
            }
        });

        res.json({ comments, count: comments.length });
    } catch (error) {
        console.error('Get comments by post error:', error);
        res.status(500).json({ error: 'Failed to fetch comments' });
    }
};

const createComment = async (req, res) => {
    try {
        const { postId, content } = req.body;
        const userId = req.user.id;

        const user = await prisma.user.findUnique({
            where: { supabaseId: userId },
            select: { id: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const post = await prisma.post.findUnique({
            where: { id: postId },
            select: { id: true }
        });

        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        const comment = await prisma.comment.create({
            data: {
                postId,
                userId: user.id,
                content
            },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                }
            }
        });

        res.status(201).json({
            message: 'Comment created successfully',
            comment
        });
    } catch (error) {
        console.error('Create comment error:', error);
        res.status(500).json({ error: 'Failed to create comment' });
    }
};

const deleteComment = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const user = await prisma.user.findUnique({
            where: { supabaseId: userId },
            select: { id: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const existingComment = await prisma.comment.findUnique({
            where: { id },
            select: { userId: true }
        });

        if (!existingComment) {
            return res.status(404).json({ error: 'Comment not found' });
        }

        if (existingComment.userId !== user.id) {
            return res.status(403).json({ error: 'Unauthorized to delete this comment' });
        }

        await prisma.comment.delete({
            where: { id }
        });

        res.json({ message: 'Comment deleted successfully' });
    } catch (error) {
        console.error('Delete comment error:', error);
        res.status(500).json({ error: 'Failed to delete comment' });
    }
};

module.exports = {
    getCommentsByPost,
    createComment,
    deleteComment
};
