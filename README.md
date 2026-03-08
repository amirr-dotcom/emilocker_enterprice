# EMI Locker Enterprise - Android Management System

A production-grade **Android Enterprise** solution built with **Flutter** and **Kotlin** to enforce device-level locks based on EMI payment status.

---

## 🚀 Project Overview

This application is designed for finance companies to manage mobile devices sold on installments. Using **Android Enterprise (Device Owner)** mode, it allows a remote administrator to "lock" a device if an EMI payment is overdue, effectively turning the phone into a restricted "Kiosk" until the payment is verified.

### **Core Features**
- **Device Owner Integration**: High-privilege administrative access that cannot be uninstalled by the user.
- **Remote Hardware Lock**: Uses `DevicePolicyManager` to enforce system-level locks.
- **Kiosk Mode (Lock Task)**: Disables Home, Recents, and Notifications when the device is locked.
- **Persistence**: Survives device reboots via a `BootReceiver`.
- **Hardened Security**: Prevents Factory Reset, Safe Boot, and Status Bar expansion.
- **Real-time Polling**: 10-second heartbeat check with the backend for lock status.
- **Offline Resilience**: Local state persistence via `SharedPreferences`.

---

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Native Implementation**: Kotlin (Android Enterprise APIs)
- **State Management**: Provider
- **Backend**: Node.js / Express (Provided Repository)
- **Database**: MongoDB

---

## 🏗 System Architecture

1. **Flutter UI**: Handles the user interface and polling logic.
2. **Method Channels**: Bridges Flutter with Kotlin for hardware-level control.
3. **Device Owner**: The app is provisioned with administrative rights.
4. **Backend API**: Serves as the source of truth for device status (`isLocked`).

---

## 📦 Installation & Setup

### **1. Backend Setup**
Navigate to the provided backend repository:
```bash
cd interview_assignment/server
npm install
npm start
```
Ensure your MongoDB is running and update the `baseUrl` in `lib/services/api_service.dart`.

### **2. Flutter App Setup**
```bash
flutter pub get
flutter run
```

---

## 🛡 Provisioning (Critical)

For the app to function as a **Device Owner**, it must be provisioned.

### **Method: ADB (For Development)**
1. Remove all accounts (Google, Samsung, etc.) from the test device.
2. Enable USB Debugging.
3. Run the following command:
```bash
adb shell dpm set-device-owner com.example.emilocker_enterprise/.MyDeviceAdminReceiver
```

*Note: Once provisioned, the app cannot be uninstalled unless the device is factory reset or the admin status is removed via ADB.*

---

## 🧪 Testing the Locker

1. Open the app and verify the status shows **"FULLY MANAGED"**.
2. Go to your backend database and set `isLocked: true` for the device ID.
3. Wait for the 10-second polling cycle.
4. The device will immediately enter **Lock Task Mode** and display the Red Lock Screen.
5. Attempt to use the phone (Swipe Home, Notifications, etc.) - all system navigation will be disabled.
6. Set `isLocked: false` in the backend to restore access.

---

## 📂 Project Structure

- `lib/platform/`: MethodChannel bridge for Kotlin communication.
- `lib/services/`: API client for backend synchronization.
- `lib/features/locker/`: Core logic and UI for the locking engine.
- `android/app/src/main/kotlin/`: Native implementation of Device Admin policies.
- `android/app/src/main/res/xml/`: Device Admin policy definition.

---

## 🎓 Concepts Learned
- Android Enterprise & MDM
- DevicePolicyManager & UserManager
- Kiosk Mode / Lock Task Mode
- MethodChannels for Native-Flutter Bridge
- Boot-level Persistence in Android

---

**Developed for the Senior Android Enterprise Assignment.**
