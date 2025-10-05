-- Trigger to automatically create user record in public.users when auth.users is created
-- This ensures consistency between Supabase Auth and the application database

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create the function that will be called by the trigger
-- SECURITY DEFINER allows the function to bypass RLS policies
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    new_username TEXT;
    new_name TEXT;
    new_avatar_url TEXT;
BEGIN
    -- Extract metadata from auth.users
    new_username := COALESCE(
        NEW.raw_user_meta_data->>'username',
        NULL
    );
    
    new_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        SPLIT_PART(NEW.email, '@', 1)
    );
    
    new_avatar_url := COALESCE(
        NEW.raw_user_meta_data->>'avatar_url',
        NEW.raw_user_meta_data->>'picture',
        NULL
    );

    -- Insert into public.users table (Prisma's users table)
    INSERT INTO public.users (
        id,
        email,
        name,
        username,
        avatar_url,
        supabase_id,
        created_at,
        updated_at
    )
    VALUES (
        gen_random_uuid(),  -- Generate new UUID for Prisma's id field
        NEW.email,
        new_name,
        new_username,
        new_avatar_url,
        NEW.id,  -- Store Supabase auth.users.id in supabase_id field
        NOW(),
        NOW()
    );
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log the error but don't fail the auth user creation
        RAISE WARNING 'Error creating user profile: %', SQLERRM;
        RETURN NEW;
END;
$$;

-- Create the trigger on auth.users table
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Grant necessary permissions
-- The function runs as SECURITY DEFINER so it has the creator's privileges
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;

-- Add comment for documentation
COMMENT ON FUNCTION public.handle_new_user() IS 
'Automatically creates a user record in public.users when a new user signs up via Supabase Auth. Runs with elevated privileges to bypass RLS.';
