#!/usr/bin/env node

/**
 * KLink Setup Verification Script
 * Checks if all configuration is correct before running the app
 */

const fs = require('fs');
const path = require('path');

console.log('\n🔍 KLink Configuration Verification\n');
console.log('=' .repeat(50));

let allChecks = true;

// Check 1: Backend .env file
console.log('\n📁 Checking Backend Configuration...');
try {
    const backendEnv = fs.readFileSync(path.join(__dirname, '.env'), 'utf8');
    
    const hasSupabaseUrl = backendEnv.includes('SUPABASE_URL=https://ecxclisijeytbcpuggxf.supabase.co');
    const hasAnonKey = backendEnv.includes('SUPABASE_ANON_KEY=');
    const hasServiceKey = backendEnv.includes('SUPABASE_SERVICE_ROLE_KEY=');
    const hasDatabaseUrl = backendEnv.includes('DATABASE_URL=');
    
    if (hasSupabaseUrl && hasAnonKey && hasServiceKey && hasDatabaseUrl) {
        console.log('   ✅ Backend .env file configured correctly');
    } else {
        console.log('   ❌ Backend .env file missing required variables');
        allChecks = false;
    }
} catch (error) {
    console.log('   ❌ Backend .env file not found');
    allChecks = false;
}

// Check 2: Frontend .env file
console.log('\n📱 Checking Frontend Configuration...');
try {
    const frontendEnv = fs.readFileSync(path.join(__dirname, '../frontend/.env'), 'utf8');
    
    const hasSupabaseUrl = frontendEnv.includes('SUPABASE_URL=https://ecxclisijeytbcpuggxf.supabase.co');
    const hasAnonKey = frontendEnv.includes('SUPABASE_KEY=');
    
    if (hasSupabaseUrl && hasAnonKey) {
        console.log('   ✅ Frontend .env file configured correctly');
    } else {
        console.log('   ❌ Frontend .env file missing required variables');
        allChecks = false;
    }
} catch (error) {
    console.log('   ❌ Frontend .env file not found');
    allChecks = false;
}

// Check 3: Node modules
console.log('\n📦 Checking Dependencies...');
try {
    const packageJson = require('./package.json');
    const nodeModulesExists = fs.existsSync(path.join(__dirname, 'node_modules'));
    
    if (nodeModulesExists) {
        console.log('   ✅ Backend node_modules installed');
        
        // Check for multer
        const multerExists = fs.existsSync(path.join(__dirname, 'node_modules/multer'));
        if (multerExists) {
            console.log('   ✅ Multer package installed (required for image upload)');
        } else {
            console.log('   ❌ Multer package not found. Run: npm install');
            allChecks = false;
        }
    } else {
        console.log('   ❌ Backend node_modules not found. Run: npm install');
        allChecks = false;
    }
} catch (error) {
    console.log('   ❌ Cannot verify dependencies');
    allChecks = false;
}

// Check 4: Required backend files
console.log('\n📄 Checking Backend Files...');
const requiredBackendFiles = [
    'src/controllers/post.controller.js',
    'src/routes/post.routes.js',
    'src/middleware/upload.middleware.js',
    'src/config/supabase.js',
];

requiredBackendFiles.forEach(file => {
    const filePath = path.join(__dirname, file);
    if (fs.existsSync(filePath)) {
        console.log(`   ✅ ${file}`);
    } else {
        console.log(`   ❌ ${file} not found`);
        allChecks = false;
    }
});

// Check 5: Required frontend files
console.log('\n📱 Checking Frontend Files...');
const requiredFrontendFiles = [
    'lib/screens/create_post/create_post_screen.dart',
    'lib/services/post_service.dart',
    'lib/services/widget_data_manager.dart',
    'lib/services/widget_background_service.dart',
];

requiredFrontendFiles.forEach(file => {
    const filePath = path.join(__dirname, '../frontend', file);
    if (fs.existsSync(filePath)) {
        console.log(`   ✅ ${file}`);
    } else {
        console.log(`   ❌ ${file} not found`);
        allChecks = false;
    }
});

// Check 6: Android widget files
console.log('\n🤖 Checking Android Widget Files...');
const requiredAndroidFiles = [
    'android/app/src/main/kotlin/com/example/frontend/KLinkWidgetProvider.kt',
    'android/app/src/main/res/layout/klink_widget.xml',
    'android/app/src/main/res/xml/klink_widget_info.xml',
];

requiredAndroidFiles.forEach(file => {
    const filePath = path.join(__dirname, '../frontend', file);
    if (fs.existsSync(filePath)) {
        console.log(`   ✅ ${file}`);
    } else {
        console.log(`   ❌ ${file} not found`);
        allChecks = false;
    }
});

// Check 7: Supabase Storage (can't check automatically)
console.log('\n☁️  Supabase Storage Configuration...');
console.log('   ⚠️  Manual verification required:');
console.log('   1. Go to Supabase Dashboard');
console.log('   2. Navigate to Storage');
console.log('   3. Create bucket named "images"');
console.log('   4. Set bucket to Public');
console.log('   See SUPABASE_STORAGE_SETUP.md for details');

// Summary
console.log('\n' + '='.repeat(50));
if (allChecks) {
    console.log('\n✅ All automated checks passed!');
    console.log('\n📋 Next Steps:');
    console.log('   1. Create Supabase Storage bucket (see SUPABASE_STORAGE_SETUP.md)');
    console.log('   2. Start backend: npm run dev');
    console.log('   3. Start frontend: flutter run');
    console.log('   4. Test post creation with image upload');
} else {
    console.log('\n❌ Some checks failed!');
    console.log('\n📋 Required Actions:');
    console.log('   1. Fix the issues marked with ❌ above');
    console.log('   2. Run this script again to verify');
    console.log('   3. See QUICK_START_GUIDE.md for setup instructions');
}

console.log('\n📚 Documentation:');
console.log('   - QUICK_START_GUIDE.md - Fast setup (15-30 min)');
console.log('   - SUPABASE_STORAGE_SETUP.md - Storage configuration');
console.log('   - WIDGET_AND_POST_CREATION_README.md - Feature details');
console.log('   - TESTING_CHECKLIST.md - Testing guide');
console.log('\n');

process.exit(allChecks ? 0 : 1);
