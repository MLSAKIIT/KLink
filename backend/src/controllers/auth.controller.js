const { supabase, supabaseAdmin } = require('../config/supabase');
const prisma = require('../config/prisma');

const ALLOWED_EMAIL_DOMAIN = process.env.ALLOWED_EMAIL_DOMAIN || '@kiit.ac.in';

const validateEmailDomain = (email) => {
    return email.endsWith(ALLOWED_EMAIL_DOMAIN);
};

const signup = async (req, res) => {
    try {
        const { email, password, fullName, username } = req.body;

        if (!validateEmailDomain(email)) {
            return res.status(400).json({
                error: `Registration is only allowed for ${ALLOWED_EMAIL_DOMAIN} email addresses`
            });
        }

        if (username) {
            const existingUser = await prisma.user.findUnique({
                where: { username }
            });
            if (existingUser) {
                return res.status(400).json({ error: 'Username already taken' });
            }
        }

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

        // Wait for database trigger to create user record
        // Implement retry logic to handle race condition
        let user = null;
        let attempts = 0;
        const maxAttempts = 5;
        const delayMs = 500;

        while (!user && attempts < maxAttempts) {
            await new Promise(resolve => setTimeout(resolve, delayMs * attempts));
            
            user = await prisma.user.findUnique({
                where: { supabaseId: authData.user.id },
                select: {
                    id: true,
                    email: true,
                    name: true,
                    username: true,
                    bio: true,
                    avatarUrl: true
                }
            });
            
            attempts++;
        }

        // If trigger didn't create the user, create it manually as fallback
        if (!user) {
            console.warn('Trigger did not create user, creating manually');
            try {
                user = await prisma.user.create({
                    data: {
                        email,
                        name: fullName,
                        username,
                        supabaseId: authData.user.id
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
            } catch (createError) {
                console.error('Failed to create user manually:', createError);
                // Clean up auth user if profile creation fails
                await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
                return res.status(500).json({ error: 'Failed to create user profile' });
            }
        }

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

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

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

const googleAuth = async (req, res) => {
    try {
        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).json({ error: 'ID token is required' });
        }

        const { data, error } = await supabase.auth.signInWithIdToken({
            provider: 'google',
            token: idToken
        });

        if (error) {
            return res.status(401).json({ error: error.message });
        }

        if (!validateEmailDomain(data.user.email)) {
            await supabaseAdmin.auth.admin.deleteUser(data.user.id);

            return res.status(403).json({
                error: `Only ${ALLOWED_EMAIL_DOMAIN} email addresses are allowed`
            });
        }

        // Use upsert to handle both new and existing users
        // This is necessary for OAuth since the trigger might not fire consistently
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

const getCurrentUser = async (req, res) => {
    try {
        const userId = req.user.id;

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

const updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { name, username, bio, avatarUrl } = req.body;

        const currentUser = await prisma.user.findUnique({
            where: { supabaseId: userId }
        });

        if (!currentUser) {
            return res.status(404).json({ error: 'User not found' });
        }

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

const getUserById = async (req, res) => {
    try {
        const { id } = req.params;
        const currentUserId = req.user?.id;

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

const searchUsers = async (req, res) => {
    try {
        const { q, limit = 20 } = req.query;

        if (!q || q.trim().length === 0) {
            return res.json({ users: [] });
        }

        const searchTerm = q.trim();

        const users = await prisma.user.findMany({
            where: {
                OR: [
                    {
                        username: {
                            contains: searchTerm,
                            mode: 'insensitive'
                        }
                    },
                    {
                        name: {
                            contains: searchTerm,
                            mode: 'insensitive'
                        }
                    },
                    {
                        email: {
                            contains: searchTerm,
                            mode: 'insensitive'
                        }
                    }
                ]
            },
            select: {
                id: true,
                email: true,
                username: true,
                name: true,
                avatarUrl: true,
                bio: true,
                createdAt: true
            },
            take: parseInt(limit),
            orderBy: {
                createdAt: 'desc'
            }
        });

        res.json({ users });
    } catch (error) {
        console.error('Search users error:', error);
        res.status(500).json({ error: 'Failed to search users' });
    }
};

module.exports = {
    signup,
    login,
    googleAuth,
    logout,
    getCurrentUser,
    updateProfile,
    getUserById,
    searchUsers
};
