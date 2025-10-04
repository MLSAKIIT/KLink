-- Reset Script: Drop all tables in public schema
-- Run this in Supabase SQL Editor to start with a clean slate

-- Drop all tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS public.likes CASCADE;
DROP TABLE IF EXISTS public.comments CASCADE;
DROP TABLE IF EXISTS public.follows CASCADE;
DROP TABLE IF EXISTS public.posts CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Drop any other tables that might exist
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public._prisma_migrations CASCADE;

-- Note: This does NOT touch the auth schema (Supabase Auth tables remain intact)
