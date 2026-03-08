import 'package:flutter/services.dart';

class DeviceManager {
  static const MethodChannel _channel = MethodChannel('com.example.emilocker/device_admin');

  /// Fetches a unique ID for the device (Android ID).
  static Future<String> getDeviceId() async {
    try {
      final String deviceId = await _channel.invokeMethod('getDeviceId');
      return deviceId;
    } on PlatformException catch (e) {
      print("Failed to get device ID: '${e.message}'.");
      return "UNKNOWN_ID";
    }
  }

  /// Checks if the app is currently the Device Owner.
  static Future<bool> isDeviceOwner() async {
    try {
      final bool isOwner = await _channel.invokeMethod('isDeviceOwner');
      return isOwner;
    } on PlatformException catch (e) {
      print("Failed to check device owner: '${e.message}'.");
      return false;
    }
  }

  /// Locks the device immediately.
  /// Requires Device Admin to be active.
  static Future<void> lockDevice() async {
    try {
      await _channel.invokeMethod('lockDevice');
    } on PlatformException catch (e) {
      print("Failed to lock device: '${e.message}'.");
    }
  }

  /// Enables or disables Kiosk Mode (Lock Task Mode).
  /// Requires Device Owner status.
  static Future<void> setKioskMode(bool active) async {
    try {
      await _channel.invokeMethod('setKioskMode', {"active": active});
    } on PlatformException catch (e) {
      print("Failed to set kiosk mode: '${e.message}'.");
    }
  }
}