import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/locker/locker_provider.dart';
import 'features/locker/lock_screen.dart';
import 'platform/device_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LockerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMI Locker Enterprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatelessWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the lock state from LockerProvider
    final isLocked = context.watch<LockerProvider>().isLocked;

    if (isLocked) {
      return const LockScreen();
    }

    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _checkOwnerStatus();
  }

  Future<void> _checkOwnerStatus() async {
    bool status = await DeviceManager.isDeviceOwner();
    setState(() {
      _isOwner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Locker Dashboard"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isOwner ? Icons.verified_user : Icons.error_outline,
              size: 80,
              color: _isOwner ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 10),
            Text(
              "Status: ${_isOwner ? "FULLY MANAGED" : "UNMANAGED"}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("EMI Status: UP TO DATE", 
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Divider(),
                    Text("Next Payment: Oct 15, 2023"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => DeviceManager.lockDevice(),
              child: const Text("Admin Test: Lock Hardware"),
            ),
            const SizedBox(height: 10),
            const Text(
              "Wait for 10s or trigger 'isLocked' in backend to see the Lock UI.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}