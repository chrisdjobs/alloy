package com.dynamjobs.alloy

import android.app.Activity
import android.content.Intent
import android.os.Bundle

/**
 * Trampoline behind the launcher aliases.
 *
 * An alias must not start [MainActivity] directly: disabling the alias that
 * owns the task makes Android finish the activity, so switching the app icon
 * would close the running session. This activity hands the launch to
 * [MainActivity] and finishes, leaving the task in charge of the real screen
 * and the aliases free to change while the app runs.
 */
class LauncherActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startActivity(
            Intent(this, MainActivity::class.java)
                .addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP,
                ),
        )
        finish()
    }
}
