import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Live Platform Analytics (GET /api/admin/rides/statistics)
  static Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/rides/statistics'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print("Error fetching stats: $e");
    }
    return null;
  }

  // 2. Pending Driver Vehicles (GET /api/admin/vehicles/pending)
  static Future<List<dynamic>> getPendingVehicles() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/vehicles/pending'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['vehicles'] ?? []);
      }
    } catch (e) {
      print("Error fetching pending vehicles: $e");
    }
    return [];
  }

  // 3. Approve Vehicle (PUT /api/admin/vehicle/{id}/approve)
  static Future<bool> approveVehicle(dynamic vehicleId) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/vehicle/$vehicleId/approve'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Reject Vehicle (PUT /api/admin/vehicle/{id}/reject)
  static Future<bool> rejectVehicle(dynamic vehicleId, String reason) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/vehicle/$vehicleId/reject'),
        headers: await _headers(),
        body: jsonEncode({'reason': reason}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. Unassigned Rides List (GET /api/rides)
  static Future<List<dynamic>> getRides() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/rides'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['rides'] ?? []);
      }
    } catch (e) {
      print("Error fetching rides: $e");
    }
    return [];
  }

  // 6. Auto-Assign Ride (PUT /api/ride/{id}/auto-assign)
  static Future<bool> autoAssignRide(dynamic rideId) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/ride/$rideId/auto-assign'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 7. Super Admin: List All Admins (GET /api/super-admin/admins)
  static Future<List<dynamic>> getSubAdmins() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/admins'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data is List ? data : (data['admins'] ?? []);
      }
    } catch (e) {
      print("Error fetching admins: $e");
    }
    return [];
  }

  // 8. Super Admin: Create Sub-Admin (POST /api/super-admin/create-admin)
  static Future<bool> createSubAdmin(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/create-admin'),
        headers: await _headers(),
        body: jsonEncode(data),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 9. Super Admin: Toggle Admin Active Status (PUT /api/super-admin/admin/{id}/status)
  static Future<bool> toggleAdminStatus(dynamic adminId) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/admin/$adminId/status'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 10. Super Admin: Delete Sub-Admin (DELETE /api/super-admin/admin/{id})
  static Future<bool> deleteAdmin(dynamic adminId) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/super-admin/admin/$adminId'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}