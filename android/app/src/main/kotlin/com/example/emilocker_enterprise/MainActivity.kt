package com.example.emilocker_enterprise

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.UserManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.emilocker/device_admin"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val adminName = ComponentName(this, MyDeviceAdminReceiver::class.java)

            when (call.method) {
                "getDeviceId" -> {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    result.success(androidId)
                }
                "isDeviceOwner" -> {
                    result.success(dpm.isDeviceOwnerApp(packageName))
                }
                "lockDevice" -> {
                    if (dpm.isAdminActive(adminName)) {
                        dpm.lockNow()
                        result.success(true)
                    } else {
                        result.error("ADMIN_NOT_ACTIVE", "Device admin is not active", null)
                    }
                }
                "setKioskMode" -> {
                    val active = call.argument<Boolean>("active") ?: false
                    if (dpm.isDeviceOwnerApp(packageName)) {
                        if (active) {
                            // Senior Level Hardening
                            dpm.setLockTaskPackages(adminName, arrayOf(packageName))
                            dpm.addUserRestriction(adminName, UserManager.DISALLOW_FACTORY_RESET)
                            dpm.addUserRestriction(adminName, UserManager.DISALLOW_SAFE_BOOT)
                            dpm.setStatusBarDisabled(adminName, true)
                            
                            startLockTask()
                        } else {
                            // Remove Restrictions
                            dpm.clearUserRestriction(adminName, UserManager.DISALLOW_FACTORY_RESET)
                            dpm.clearUserRestriction(adminName, UserManager.DISALLOW_SAFE_BOOT)
                            dpm.setStatusBarDisabled(adminName, false)

                            stopLockTask()
                        }
                        result.success(true)
                    } else {
                        result.error("NOT_DEVICE_OWNER", "App is not device owner", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}