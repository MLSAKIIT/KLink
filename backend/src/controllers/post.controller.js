const prisma = require('../config/prisma');
const { uploadToSupabase, deleteFromSupabase } = require('../middleware/upload.middleware');

const getAllPosts = async (req, res) => {
    try {
        const { limit = 20, offset = 0 } = req.query;
        const currentUserId = req.user?.id;

        let currentUserInternalId = null;
        if (currentUserId) {
            const currentUser = await prisma.user.findUnique({
                where: { supabaseId: currentUserId },
                select: { id: true }
            });
            currentUserInternalId = currentUser?.id;
        }

        const posts = await prisma.post.findMany({
            take: parseInt(limit),
            skip: parseInt(offset),
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                },
                _count: {
                    select: {
                        comments: true,
                        likes: true
                    }
                },
                ...(currentUserInternalId && {
                    likes: {
                        where: {
                            userId: currentUserInternalId
                        },
                        select: {
                            id: true
                        }
                    }
                })
            }
        });

        const transformedPosts = posts.map(post => ({
            ...post,
            commentCount: post._count.comments,
            likeCount: post._count.likes,
            isLiked: currentUserInternalId ? post.likes?.length > 0 : false,
            _count: undefined,
            likes: undefined
        }));

        res.json({ 
            posts: transformedPosts, 
            count: transformedPosts.length 
        });
    } catch (error) {
        console.error('Get all posts error:', error);
        res.status(500).json({ error: 'Failed to fetch posts' });
    }
};

const getPostById = async (req, res) => {
    try {
        const { id } = req.params;
        const currentUserId = req.user?.id;

        let currentUserInternalId = null;
        if (currentUserId) {
            const currentUser = await prisma.user.findUnique({
                where: { supabaseId: currentUserId },
                select: { id: true }
            });
            currentUserInternalId = currentUser?.id;
        }

        const post = await prisma.post.findUnique({
            where: { id },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                },
                _count: {
                    select: {
                        comments: true,
                        likes: true
                    }
                },
                ...(currentUserInternalId && {
                    likes: {
                        where: {
                            userId: currentUserInternalId
                        },
                        select: {
                            id: true
                        }
                    }
                })
            }
        });

        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        res.json({ 
            post: {
                ...post,
                commentCount: post._count.comments,
                likeCount: post._count.likes,
                isLiked: currentUserInternalId ? post.likes?.length > 0 : false,
                _count: undefined,
                likes: undefined
            }
        });
    } catch (error) {
        console.error('Get post by ID error:', error);
        res.status(500).json({ error: 'Failed to fetch post' });
    }
};

const getUserPosts = async (req, res) => {
    try {
        const { userId } = req.params;
        const { limit = 20, offset = 0 } = req.query;
        const currentUserId = req.user?.id;

        const user = await prisma.user.findFirst({
            where: {
                OR: [
                    { id: userId },
                    { username: userId }
                ]
            },
            select: { id: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        let currentUserInternalId = null;
        if (currentUserId) {
            const currentUser = await prisma.user.findUnique({
                where: { supabaseId: currentUserId },
                select: { id: true }
            });
            currentUserInternalId = currentUser?.id;
        }

        const posts = await prisma.post.findMany({
            where: { userId: user.id },
            take: parseInt(limit),
            skip: parseInt(offset),
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                },
                _count: {
                    select: {
                        comments: true,
                        likes: true
                    }
                },
                ...(currentUserInternalId && {
                    likes: {
                        where: {
                            userId: currentUserInternalId
                        },
                        select: {
                            id: true
                        }
                    }
                })
            }
        });

        const transformedPosts = posts.map(post => ({
            ...post,
            commentCount: post._count.comments,
            likeCount: post._count.likes,
            isLiked: currentUserInternalId ? post.likes?.length > 0 : false,
            _count: undefined,
            likes: undefined
        }));

        res.json({ posts: transformedPosts, count: transformedPosts.length });
    } catch (error) {
        console.error('Get user posts error:', error);
        res.status(500).json({ error: 'Failed to fetch user posts' });
    }
};

const createPost = async (req, res) => {
    try {
        const { content, imageUrl } = req.body;
        const userId = req.user.id;

        const user = await prisma.user.findUnique({
            where: { supabaseId: userId },
            select: { id: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const post = await prisma.post.create({
            data: {
                userId: user.id,
                content,
                imageUrl: imageUrl || null
            },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                },
                _count: {
                    select: {
                        comments: true,
                        likes: true
                    }
                }
            }
        });

        res.status(201).json({
            message: 'Post created successfully',
            post: {
                id: post.id,
                content: post.content,
                imageUrl: post.imageUrl,
                userId: post.userId,
                createdAt: post.createdAt,
                updatedAt: post.updatedAt,
                user: post.user,
                commentCount: post._count.comments,
                likeCount: post._count.likes,
                isLiked: false
            }
        });
    } catch (error) {
        console.error('Create post error:', error);
        res.status(500).json({ error: 'Failed to create post' });
    }
};

const updatePost = async (req, res) => {
    try {
        const { id } = req.params;
        const { content, imageUrl } = req.body;
        const userId = req.user.id;

        const user = await prisma.user.findUnique({
            where: { supabaseId: userId },
            select: { id: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const existingPost = await prisma.post.findUnique({
            where: { id },
            select: { userId: true }
        });

        if (!existingPost) {
            return res.status(404).json({ error: 'Post not found' });
        }

        if (existingPost.userId !== user.id) {
            return res.status(403).json({ error: 'Unauthorized to update this post' });
        }

        const updateData = {};
        if (content !== undefined) updateData.content = content;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;

        const post = await prisma.post.update({
            where: { id },
            data: updateData,
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                },
                _count: {
                    select: {
                        comments: true,
                        likes: true
                    }
                }
            }
        });

        res.json({
            message: 'Post updated successfully',
            post: {
                ...post,
                commentCount: post._count.comments,
                likeCount: post._count.likes,
                _count: undefined
            }
        });
    } catch (error) {
        console.error('Update post error:', error);
        res.status(500).json({ error: 'Failed to update post' });
    }
};

const deletePost = async (req, res) => {
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

        const existingPost = await prisma.post.findUnique({
            where: { id },
            select: { userId: true }
        });

        if (!existingPost) {
            return res.status(404).json({ error: 'Post not found' });
        }

        if (existingPost.userId !== user.id) {
            return res.status(403).json({ error: 'Unauthorized to delete this post' });
        }

        await prisma.post.delete({
            where: { id }
        });

        res.json({ message: 'Post deleted successfully' });
    } catch (error) {
        console.error('Delete post error:', error);
        res.status(500).json({ error: 'Failed to delete post' });
    }
};

const likePost = async (req, res) => {
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

        const post = await prisma.post.findUnique({
            where: { id },
            select: { id: true }
        });

        if (!post) {
            return res.status(404).json({ error: 'Post not found' });
        }

        const existingLike = await prisma.like.findUnique({
            where: {
                postId_userId: {
                    postId: id,
                    userId: user.id
                }
            }
        });

        if (existingLike) {
            return res.status(400).json({ error: 'Post already liked' });
        }

        const like = await prisma.like.create({
            data: {
                postId: id,
                userId: user.id
            }
        });

        res.status(201).json({
            message: 'Post liked successfully',
            like
        });
    } catch (error) {
        console.error('Like post error:', error);
        res.status(500).json({ error: 'Failed to like post' });
    }
};

const unlikePost = async (req, res) => {
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

        await prisma.like.delete({
            where: {
                postId_userId: {
                    postId: id,
                    userId: user.id
                }
            }
        });

        res.json({ message: 'Post unliked successfully' });
    } catch (error) {
        console.error('Unlike post error:', error);
        res.status(500).json({ error: 'Failed to unlike post' });
    }
};

const uploadImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image file provided' });
        }

        const imageUrl = await uploadToSupabase(req.file, 'posts');
        
        res.status(200).json({
            message: 'Image uploaded successfully',
            imageUrl
        });
    } catch (error) {
        console.error('Upload image error:', error);
        res.status(500).json({ error: error.message || 'Failed to upload image' });
    }
};

const getFollowingPosts = async (req, res) => {
    try {
        const { limit = 10 } = req.query;
        const userId = req.user.id;

        const user = await prisma.user.findUnique({
            where: { supabaseId: userId },
            select: { id: true }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        const following = await prisma.follow.findMany({
            where: { followerId: user.id },
            select: { followingId: true }
        });

        const followingIds = following.map(f => f.followingId);

        const posts = await prisma.post.findMany({
            where: {
                userId: { in: followingIds },
                imageUrl: { not: null } // Only posts with images for widget
            },
            take: parseInt(limit),
            orderBy: { createdAt: 'desc' },
            include: {
                user: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true
                    }
                },
                _count: {
                    select: {
                        comments: true,
                        likes: true
                    }
                }
            }
        });

        const transformedPosts = posts.map(post => ({
            ...post,
            commentCount: post._count.comments,
            likeCount: post._count.likes,
            isLiked: false,
            _count: undefined
        }));

        res.json({ posts: transformedPosts, count: transformedPosts.length });
    } catch (error) {
        console.error('Get following posts error:', error);
        res.status(500).json({ error: 'Failed to fetch following posts' });
    }
};

module.exports = {
    getAllPosts,
    getPostById,
    getUserPosts,
    createPost,
    updatePost,
    deletePost,
    likePost,
    unlikePost,
    uploadImage,
    getFollowingPosts
};
