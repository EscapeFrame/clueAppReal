package com.example.clue

import dev.fluttercommunity.workmanager.WorkmanagerPlugin
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import com.whelksoft.flutter_native_timezone.FlutterNativeTimezonePlugin
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import io.flutter.app.FlutterApplication

class App : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        WorkmanagerPlugin.setPluginRegistrantCallback(::registerPlugins)
    }

    private fun registerPlugins(engine: FlutterEngine) {
        engine.plugins.add(FlutterLocalNotificationsPlugin())
        engine.plugins.add(SharedPreferencesPlugin())
        engine.plugins.add(FlutterNativeTimezonePlugin())
    }
}
