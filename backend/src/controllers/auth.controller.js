const { supabase, supabaseAdmin } = require('../config/supabase');
const prisma = require('../config/prisma');

const ALLOWED_EMAIL_DOMAIN = process.env.ALLOWED_EMAIL_DOMAIN || '@kiit.ac.in';

/**
 * Validate email domain
 */
const validateEmailDomain = (email) => {
    return email.endsWith(ALLOWED_EMAIL_DOMAIN);
};

/**
 * Sign up new user with Supabase Auth and Prisma
 */
const signup = async (req, res) => {
    try {
        const { email, password, fullName, username } = req.body;

        // Validate email domain
        if (!validateEmailDomain(email)) {
            return res.status(400).json({
                error: `Registration is only allowed for ${ALLOWED_EMAIL_DOMAIN} email addresses`
            });
        }

        // Check if username is already taken in Prisma
        if (username) {
            const existingUser = await prisma.user.findUnique({
                where: { username }
            });
            if (existingUser) {
                return res.status(400).json({ error: 'Username already taken' });
            }
        }

        // Create user with Supabase Auth
        const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
            email,
            password,
            email_confirm: true,
            user_metadata: {
                full_name: fullName,
                username: username
            }
        });

        if (authError) {
            console.error('Signup error:', authError);
            return res.status(400).json({ error: authError.message });
        }

        // Create user profile in Prisma
        const user = await prisma.user.create({
            data: {
                email,
                name: fullName,
                username,
                supabaseId: authData.user.id
            }
        });

        // Sign in to get session token
        const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (signInError) {
            console.error('Sign in error:', signInError);
            return res.status(400).json({ error: signInError.message });
        }

        res.status(201).json({
            message: 'User created successfully',
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                username: user.username
            },
            session: signInData.session
        });
    } catch (error) {
        console.error('Signup error:', error);
        res.status(500).json({ error: 'Failed to create user' });
    }
};

/**
 * Login user
 */
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate email domain
        if (!validateEmailDomain(email)) {
            return res.status(400).json({
                error: `Login is only allowed for ${ALLOWED_EMAIL_DOMAIN} email addresses`
            });
        }

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) {
            return res.status(401).json({ error: error.message });
        }

        // Get user profile from Prisma
        const user = await prisma.user.findUnique({
            where: { supabaseId: data.user.id },
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                bio: true,
                avatarUrl: true,
                createdAt: true
            }
        });

        res.json({
            message: 'Login successful',
            user,
            session: data.session
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Failed to login' });
    }
};

/**
 * Google OAuth authentication
 */
const googleAuth = async (req, res) => {
    try {
        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).json({ error: 'ID token is required' });
        }

        // Verify Google token and sign in
        const { data, error } = await supabase.auth.signInWithIdToken({
            provider: 'google',
            token: idToken
        });

        if (error) {
            return res.status(401).json({ error: error.message });
        }

        // Validate email domain
        if (!validateEmailDomain(data.user.email)) {
            // Delete the user if email domain is not allowed
            await supabaseAdmin.auth.admin.deleteUser(data.user.id);

            return res.status(403).json({
                error: `Only ${ALLOWED_EMAIL_DOMAIN} email addresses are allowed`
            });
        }

        // Create or update user profile in Prisma
        const user = await prisma.user.upsert({
            where: { supabaseId: data.user.id },
            update: {
                email: data.user.email,
                name: data.user.user_metadata.full_name || data.user.user_metadata.name || data.user.email.split('@')[0],
                avatarUrl: data.user.user_metadata.avatar_url || data.user.user_metadata.picture
            },
            create: {
                email: data.user.email,
                name: data.user.user_metadata.full_name || data.user.user_metadata.name || data.user.email.split('@')[0],
                avatarUrl: data.user.user_metadata.avatar_url || data.user.user_metadata.picture,
                supabaseId: data.user.id
            },
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                bio: true,
                avatarUrl: true
            }
        });

        res.json({
            message: 'Google authentication successful',
            user,
            session: data.session
        });
    } catch (error) {
        console.error('Google auth error:', error);
        res.status(500).json({ error: 'Failed to authenticate with Google' });
    }
};

/**
 * Logout user
 */
const logout = async (req, res) => {
    try {
        const { error } = await supabase.auth.signOut();

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        res.json({ message: 'Logout successful' });
    } catch (error) {
        console.error('Logout error:', error);
        res.status(500).json({ error: 'Failed to logout' });
    }
};

/**
 * Get current user
 */
const getCurrentUser = async (req, res) => {
    try {
        // User is already attached by auth middleware
        const userId = req.user.id;

        // Get user profile from Prisma
        const user = await prisma.user.findUnique({
            where: { supabaseId: userId },
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                bio: true,
                avatarUrl: true,
                createdAt: true,
                _count: {
                    select: {
                        posts: true,
                        followers: true,
                        following: true
                    }
                }
            }
        });

        if (!user) {
            return res.status(404).json({ error: 'Profile not found' });
        }

        res.json({
            user: {
                ...user,
                postsCount: user._count.posts,
                followersCount: user._count.followers,
                followingCount: user._count.following,
                _count: undefined
            },
            supabaseUser: req.user
        });
    } catch (error) {
        console.error('Get current user error:', error);
        res.status(500).json({ error: 'Failed to get current user' });
    }
};

/**
 * Update user profile
 */
const updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, username, bio, avatarUrl } = req.body;

        // Get user from Prisma using supabaseId
        const currentUser = await prisma.user.findUnique({
            where: { supabaseId: userId }
        });

        if (!currentUser) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if username is already taken by another user
        if (username) {
            const existingUser = await prisma.user.findFirst({
                where: {
                    username,
                    NOT: { id: currentUser.id }
                }
            });
            if (existingUser) {
                return res.status(400).json({ error: 'Username already taken' });
            }
        }

        // Update user profile
        const user = await prisma.user.update({
            where: { id: currentUser.id },
            data: {
                ...(name && { name }),
                ...(username !== undefined && { username }),
                ...(bio !== undefined && { bio }),
                ...(avatarUrl !== undefined && { avatarUrl })
            },
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                bio: true,
                avatarUrl: true,
                createdAt: true
            }
        });

        res.json({
            message: 'Profile updated successfully',
            user
        });
    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({ error: 'Failed to update profile' });
    }
};

/**
 * Get user by ID or username
 */
const getUserById = async (req, res) => {
    try {
        const { id } = req.params;
        const currentUserId = req.user?.id;

        // Try to find by ID first, then by username
        const user = await prisma.user.findFirst({
            where: {
                OR: [
                    { id },
                    { username: id }
                ]
            },
            select: {
                id: true,
                email: true,
                name: true,
                username: true,
                bio: true,
                avatarUrl: true,
                createdAt: true,
                _count: {
                    select: {
                        posts: true,
                        followers: true,
                        following: true
                    }
                }
            }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if current user follows this user
        let isFollowing = false;
        if (currentUserId) {
            const currentUser = await prisma.user.findUnique({
                where: { supabaseId: currentUserId }
            });
            
            if (currentUser) {
                const follow = await prisma.follow.findUnique({
                    where: {
                        followerId_followingId: {
                            followerId: currentUser.id,
                            followingId: user.id
                        }
                    }
                });
                isFollowing = !!follow;
            }
        }

        res.json({
            user: {
                ...user,
                postsCount: user._count.posts,
                followersCount: user._count.followers,
                followingCount: user._count.following,
                isFollowing,
                _count: undefined
            }
        });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(500).json({ error: 'Failed to get user' });
    }
};

module.exports = {
    signup,
    login,
    googleAuth,
    logout,
    getCurrentUser,
    updateProfile,
    getUserById
};
