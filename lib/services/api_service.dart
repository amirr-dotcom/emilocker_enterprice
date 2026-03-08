import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // REPLACE THIS with your local IP when testing on a real device
  static const String baseUrl = 'http://localhost:3000/api';

  /// Registers the device on the backend if it doesn't exist.
  static Future<bool> registerDevice(String deviceId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          'status': 'active',
          'isLocked': false,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Registration Error: $e");
      return false;
    }
  }

  /// Fetches the lock status for the device.
  static Future<Map<String, dynamic>> getDeviceStatus(String deviceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices/$deviceId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'isLocked': false};
    } catch (e) {
      print("API Error: $e");
      return {'isLocked': false};
    }
  }
}