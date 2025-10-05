-- Update RLS policies to work properly with triggers
-- This should be run after Prisma migrations are complete

-- First, ensure the users table has RLS enabled
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users are viewable by everyone" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;

-- Policy: Anyone can view user profiles (for public profiles)
CREATE POLICY "Users are viewable by everyone"
    ON public.users
    FOR SELECT
    USING (true);

-- Policy: Service role can insert (for trigger function)
-- Note: We don't need an INSERT policy for regular users because
-- the trigger function runs as SECURITY DEFINER
CREATE POLICY "Service role can insert users"
    ON public.users
    FOR INSERT
    WITH CHECK (true);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update their own profile"
    ON public.users
    FOR UPDATE
    USING (auth.uid()::text = supabase_id)
    WITH CHECK (auth.uid()::text = supabase_id);

-- Policy: Users cannot delete themselves (admin only)
-- If you want users to be able to delete their own account, modify this
CREATE POLICY "Only service role can delete users"
    ON public.users
    FOR DELETE
    USING (false);

-- Ensure proper permissions for the trigger function
-- The function should be owned by postgres or a superuser
ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

-- Grant necessary schema permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.users TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.posts TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.comments TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.follows TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.likes TO authenticated;

-- Add comments for documentation
COMMENT ON POLICY "Users are viewable by everyone" ON public.users IS 
'Allows anyone to view user profiles for public access';

COMMENT ON POLICY "Service role can insert users" ON public.users IS 
'Allows the trigger function and service role to create user records';

COMMENT ON POLICY "Users can update their own profile" ON public.users IS 
'Users can only update their own profile information';

COMMENT ON POLICY "Only service role can delete users" ON public.users IS 
'User deletion is restricted to prevent accidental data loss';
