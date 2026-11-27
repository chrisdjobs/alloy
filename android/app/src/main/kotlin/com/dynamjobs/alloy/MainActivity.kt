package com.dynamjobs.alloy

import android.content.ComponentName
import android.content.pm.PackageManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_ICON_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "setIcon") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val id = call.argument<String>("id")
                if (id == null) {
                    result.error("invalid", "Missing icon id", null)
                    return@setMethodCallHandler
                }
                try {
                    applyIcon(id)
                    result.success(null)
                } catch (error: Exception) {
                    result.error("icon", error.message, null)
                }
            }
    }

    /**
     * Enables the launcher alias of [id] and hides the rest.
     *
     * Safe while the app runs: the aliases start [LauncherActivity], so no
     * live activity belongs to the alias being disabled. DONT_KILL_APP keeps
     * the playback service alive; the launcher refreshes the icon when the
     * user leaves the app.
     */
    private fun applyIcon(id: String) {
        val target = aliasOf(id)
        val aliases = launcherAliases()
        require(target in aliases) { "Unknown app icon: $id" }
        for (alias in aliases) {
            val state = if (alias == target) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            packageManager.setComponentEnabledSetting(
                ComponentName(packageName, alias),
                state,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    /** Launcher alias that belongs to the preset [id]. */
    private fun aliasOf(id: String): String {
        val suffix = id.replace("-", "_").replaceFirstChar { it.uppercaseChar() }
        return "$packageName.MainActivity$suffix"
    }

    /**
     * Every activity alias that points at [LauncherActivity].
     *
     * MATCH_DISABLED_COMPONENTS matters: the aliases of the presets that are
     * not active are disabled, and without the flag they are left out of the
     * list, so switching back to them would fail.
     */
    @Suppress("DEPRECATION")
    private fun launcherAliases(): List<String> {
        val flags = PackageManager.GET_ACTIVITIES or
            PackageManager.MATCH_DISABLED_COMPONENTS
        val info = packageManager.getPackageInfo(packageName, flags)
        return info.activities.orEmpty()
            .map { it.name }
            .filter { it.startsWith("$packageName.MainActivity") && it != "$packageName.MainActivity" }
    }

    private companion object {
        const val APP_ICON_CHANNEL = "com.dynamjobs.alloy/app_icon"
    }
}
