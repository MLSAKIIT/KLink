const prisma = require('../config/prisma');

/**
 * Follow a user
 */
const followUser = async (req, res) => {
    try {
        const { userId } = req.params;
        const followerId = req.user.id;

        // Get follower's internal ID
        const followerUser = await prisma.user.findUnique({
            where: { supabaseId: followerId },
            select: { id: true }
        });

        if (!followerUser) {
            return res.status(404).json({ error: 'Follower user not found' });
        }

        // Find target user by ID or username
        const targetUser = await prisma.user.findFirst({
            where: {
                OR: [
                    { id: userId },
                    { username: userId }
                ]
            },
            select: { id: true }
        });

        if (!targetUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Can't follow yourself
        if (targetUser.id === followerUser.id) {
            return res.status(400).json({ error: 'Cannot follow yourself' });
        }

        // Check if already following
        const existingFollow = await prisma.follow.findUnique({
            where: {
                followerId_followingId: {
                    followerId: followerUser.id,
                    followingId: targetUser.id
                }
            }
        });

        if (existingFollow) {
            return res.status(400).json({ error: 'Already following this user' });
        }

        const follow = await prisma.follow.create({
            data: {
                followerId: followerUser.id,
                followingId: targetUser.id
            }
        });

        res.status(201).json({
            message: 'User followed successfully',
            follow
        });
    } catch (error) {
        console.error('Follow user error:', error);
        res.status(500).json({ error: 'Failed to follow user' });
    }
};

/**
 * Unfollow a user
 */
const unfollowUser = async (req, res) => {
    try {
        const { userId } = req.params;
        const followerId = req.user.id;

        // Get follower's internal ID
        const followerUser = await prisma.user.findUnique({
            where: { supabaseId: followerId },
            select: { id: true }
        });

        if (!followerUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Find target user by ID or username
        const targetUser = await prisma.user.findFirst({
            where: {
                OR: [
                    { id: userId },
                    { username: userId }
                ]
            },
            select: { id: true }
        });

        if (!targetUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        await prisma.follow.delete({
            where: {
                followerId_followingId: {
                    followerId: followerUser.id,
                    followingId: targetUser.id
                }
            }
        });

        res.json({ message: 'User unfollowed successfully' });
    } catch (error) {
        console.error('Unfollow user error:', error);
        res.status(500).json({ error: 'Failed to unfollow user' });
    }
};

/**
 * Get user's followers
 */
const getFollowers = async (req, res) => {
    try {
        const { userId } = req.params;
        const { limit = 50, offset = 0 } = req.query;

        // Find user by ID or username
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

        const followers = await prisma.follow.findMany({
            where: { followingId: user.id },
            take: parseInt(limit),
            skip: parseInt(offset),
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                follower: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true,
                        bio: true
                    }
                }
            }
        });

        res.json({ followers, count: followers.length });
    } catch (error) {
        console.error('Get followers error:', error);
        res.status(500).json({ error: 'Failed to fetch followers' });
    }
};

/**
 * Get users that user follows
 */
const getFollowing = async (req, res) => {
    try {
        const { userId } = req.params;
        const { limit = 50, offset = 0 } = req.query;

        // Find user by ID or username
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

        const following = await prisma.follow.findMany({
            where: { followerId: user.id },
            take: parseInt(limit),
            skip: parseInt(offset),
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                following: {
                    select: {
                        id: true,
                        username: true,
                        name: true,
                        avatarUrl: true,
                        bio: true
                    }
                }
            }
        });

        res.json({ following, count: following.length });
    } catch (error) {
        console.error('Get following error:', error);
        res.status(500).json({ error: 'Failed to fetch following' });
    }
};

/**
 * Check if current user is following another user
 */
const checkFollowing = async (req, res) => {
    try {
        const { userId } = req.params;
        const followerId = req.user.id;

        // Get follower's internal ID
        const followerUser = await prisma.user.findUnique({
            where: { supabaseId: followerId },
            select: { id: true }
        });

        if (!followerUser) {
            return res.json({ isFollowing: false });
        }

        // Find target user by ID or username
        const targetUser = await prisma.user.findFirst({
            where: {
                OR: [
                    { id: userId },
                    { username: userId }
                ]
            },
            select: { id: true }
        });

        if (!targetUser) {
            return res.json({ isFollowing: false });
        }

        const follow = await prisma.follow.findUnique({
            where: {
                followerId_followingId: {
                    followerId: followerUser.id,
                    followingId: targetUser.id
                }
            }
        });

        res.json({ isFollowing: !!follow });
    } catch (error) {
        console.error('Check following error:', error);
        res.status(500).json({ error: 'Failed to check following status' });
    }
};

module.exports = {
    followUser,
    unfollowUser,
    getFollowers,
    getFollowing,
    checkFollowing
};
