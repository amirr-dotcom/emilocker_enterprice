import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../platform/device_manager.dart';
import '../../services/api_service.dart';

class LockerProvider extends ChangeNotifier {
  bool _isLocked = false;
  bool get isLocked => _isLocked;

  Timer? _pollingTimer;
  String _deviceId = "UNKNOWN";

  LockerProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _deviceId = await DeviceManager.getDeviceId();
    
    // Load last known lock state from local storage
    final prefs = await SharedPreferences.getInstance();
    _isLocked = prefs.getBool('is_locked_state') ?? false;
    
    // Ensure hardware reflects last known state immediately on boot
    if (_isLocked) {
      await DeviceManager.setKioskMode(true);
    }
    
    // Register device if not already registered
    bool isRegistered = prefs.getBool('is_registered') ?? false;
    if (!isRegistered) {
      bool success = await ApiService.registerDevice(_deviceId);
      if (success) {
        await prefs.setBool('is_registered', true);
      }
    }

    startPolling();
    notifyListeners();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await checkLockStatus();
    });
  }

  Future<void> checkLockStatus() async {
    if (_deviceId == "UNKNOWN") return;

    try {
      final status = await ApiService.getDeviceStatus(_deviceId);
      bool lockedFromServer = status['isLocked'] ?? false;

      if (lockedFromServer != _isLocked) {
        _isLocked = lockedFromServer;
        
        // Persist the state locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_locked_state', _isLocked);
        
        // Handle Hardware Level Lock/Unlock
        if (_isLocked) {
          await DeviceManager.setKioskMode(true);
        } else {
          await DeviceManager.setKioskMode(false);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print("Error checking lock status (possibly offline): $e");
      // If offline, we keep the last known state (_isLocked)
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}