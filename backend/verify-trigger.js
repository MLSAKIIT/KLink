/**
 * Database Trigger Verification Script
 * 
 * This script verifies that the database trigger is working correctly
 * by creating a test user and checking if the profile is auto-created.
 * 
 * Usage: node backend/verify-trigger.js
 */

const { supabaseAdmin } = require('./src/config/supabase');
const prisma = require('./src/config/prisma');

const TEST_EMAIL_PREFIX = 'test-trigger-';
const TEST_PASSWORD = 'test123456789';

async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function verifyTrigger() {
    console.log('🔍 Starting Database Trigger Verification...\n');
    
    const testEmail = `${TEST_EMAIL_PREFIX}${Date.now()}@kiit.ac.in`;
    let authUserId = null;
    let dbUserId = null;
    
    try {
        // Step 1: Create auth user
        console.log('📝 Step 1: Creating test auth user...');
        const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
            email: testEmail,
            password: TEST_PASSWORD,
            email_confirm: true,
            user_metadata: {
                full_name: 'Test User',
                username: `testuser${Date.now()}`
            }
        });
        
        if (authError) {
            console.error('❌ Failed to create auth user:', authError.message);
            return false;
        }
        
        authUserId = authData.user.id;
        console.log(`✅ Auth user created with ID: ${authUserId}`);
        
        // Step 2: Wait for trigger to execute
        console.log('\n⏳ Step 2: Waiting for trigger to execute (2 seconds)...');
        await sleep(2000);
        
        // Step 3: Check if database user was created
        console.log('\n🔎 Step 3: Checking for database user record...');
        const dbUser = await prisma.user.findUnique({
            where: { supabaseId: authUserId }
        });
        
        if (!dbUser) {
            console.error('❌ FAILED: Database user record was NOT created by trigger!');
            console.log('\n📋 Troubleshooting steps:');
            console.log('1. Make sure you ran trigger_create_user.sql in Supabase SQL Editor');
            console.log('2. Check Supabase logs for trigger errors');
            console.log('3. Verify trigger exists: SELECT * FROM pg_trigger WHERE tgname = \'on_auth_user_created\';');
            console.log('4. Check function security: SELECT proname, prosecdef FROM pg_proc WHERE proname = \'handle_new_user\';');
            return false;
        }
        
        dbUserId = dbUser.id;
        console.log(`✅ Database user created with ID: ${dbUser.id}`);
        
        // Step 4: Verify data integrity
        console.log('\n✔️  Step 4: Verifying data integrity...');
        const checks = [];
        
        if (dbUser.email === testEmail) {
            console.log('  ✅ Email matches');
            checks.push(true);
        } else {
            console.log(`  ❌ Email mismatch: ${dbUser.email} !== ${testEmail}`);
            checks.push(false);
        }
        
        if (dbUser.supabaseId === authUserId) {
            console.log('  ✅ Supabase ID matches');
            checks.push(true);
        } else {
            console.log(`  ❌ Supabase ID mismatch: ${dbUser.supabaseId} !== ${authUserId}`);
            checks.push(false);
        }
        
        if (dbUser.name) {
            console.log(`  ✅ Name populated: ${dbUser.name}`);
            checks.push(true);
        } else {
            console.log('  ⚠️  Name not populated (optional)');
        }
        
        if (dbUser.createdAt) {
            console.log(`  ✅ Timestamps populated: ${dbUser.createdAt.toISOString()}`);
            checks.push(true);
        } else {
            console.log('  ❌ Timestamps missing');
            checks.push(false);
        }
        
        const allChecksPassed = checks.every(check => check === true);
        
        if (allChecksPassed) {
            console.log('\n🎉 SUCCESS! Database trigger is working correctly!');
            console.log('\n✨ Your setup is ready for production.');
            return true;
        } else {
            console.log('\n⚠️  WARNING: Trigger works but some data fields need attention.');
            return false;
        }
        
    } catch (error) {
        console.error('\n❌ Error during verification:', error.message);
        console.error(error);
        return false;
    } finally {
        // Cleanup
        console.log('\n🧹 Cleaning up test data...');
        try {
            if (authUserId) {
                await supabaseAdmin.auth.admin.deleteUser(authUserId);
                console.log('  ✅ Deleted auth user');
            }
            if (dbUserId) {
                await prisma.user.delete({ where: { id: dbUserId } });
                console.log('  ✅ Deleted database user');
            }
            console.log('✅ Cleanup completed');
        } catch (cleanupError) {
            console.error('⚠️  Cleanup error (manual cleanup may be needed):', cleanupError.message);
        }
    }
}

async function checkOrphanedUsers() {
    console.log('\n📊 Checking for orphaned auth users...');
    
    try {
        // Get all auth users via Supabase Admin
        const { data: authUsers, error } = await supabaseAdmin.auth.admin.listUsers();
        
        if (error) {
            console.error('❌ Failed to list auth users:', error.message);
            return;
        }
        
        console.log(`Found ${authUsers.users.length} auth users`);
        
        // Check each auth user
        let orphanCount = 0;
        for (const authUser of authUsers.users) {
            const dbUser = await prisma.user.findUnique({
                where: { supabaseId: authUser.id }
            });
            
            if (!dbUser) {
                orphanCount++;
                console.log(`  ⚠️  Orphaned: ${authUser.email} (${authUser.id})`);
            }
        }
        
        if (orphanCount === 0) {
            console.log('✅ No orphaned users found!');
        } else {
            console.log(`\n⚠️  Found ${orphanCount} orphaned auth user(s)`);
            console.log('\n📝 To fix orphaned users, run this SQL in Supabase:');
            console.log(`
INSERT INTO public.users (id, email, name, supabase_id, created_at, updated_at)
SELECT 
  gen_random_uuid(),
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', SPLIT_PART(au.email, '@', 1)),
  au.id,
  au.created_at,
  NOW()
FROM auth.users au
LEFT JOIN public.users u ON au.id = u.supabase_id
WHERE u.id IS NULL;
            `);
        }
    } catch (error) {
        console.error('❌ Error checking orphaned users:', error.message);
    }
}

async function main() {
    console.log('═══════════════════════════════════════════════════════════');
    console.log('   KLink Database Trigger Verification');
    console.log('═══════════════════════════════════════════════════════════\n');
    
    const success = await verifyTrigger();
    
    console.log('\n───────────────────────────────────────────────────────────\n');
    
    await checkOrphanedUsers();
    
    console.log('\n═══════════════════════════════════════════════════════════');
    console.log(success ? '   ✅ Verification Complete' : '   ❌ Verification Failed');
    console.log('═══════════════════════════════════════════════════════════\n');
    
    process.exit(success ? 0 : 1);
}

// Run if called directly
if (require.main === module) {
    main().catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}

module.exports = { verifyTrigger, checkOrphanedUsers };
