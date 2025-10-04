-- Trigger to automatically delete user from users table when deleted from auth.users
-- This ensures data consistency between Supabase Auth and our application database

-- First, drop the trigger and function if they exist
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;
DROP FUNCTION IF EXISTS handle_auth_user_deleted();

-- Create the function that will be called by the trigger
CREATE OR REPLACE FUNCTION handle_auth_user_deleted()
RETURNS TRIGGER AS $$
BEGIN
  -- Delete the user from the public.users table when deleted from auth.users
  DELETE FROM public.users WHERE supabase_id = OLD.id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger on auth.users table
CREATE TRIGGER on_auth_user_deleted
  AFTER DELETE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_auth_user_deleted();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
