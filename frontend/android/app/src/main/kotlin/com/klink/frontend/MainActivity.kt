package com.klink.frontend

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Bundle

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        // Handle deep link for OAuth callback
        intent?.data?.let { uri ->
            // The Flutter app will handle the deep link through Supabase
            // This ensures the link is properly passed to Flutter
        }
    }
}
