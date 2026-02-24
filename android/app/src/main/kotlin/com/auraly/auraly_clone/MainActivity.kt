package com.auraly.auraly_clone

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Forward the new intent to the Flutter engine
        // receive_sharing_intent package will handle it
        setIntent(intent)
    }
}
