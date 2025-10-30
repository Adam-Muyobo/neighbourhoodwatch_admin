import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/sos_alert.dart';

class SosService {
  static final SosService _instance = SosService._internal();
  factory SosService() => _instance;
  SosService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all SOS alerts
  Future<List<SosAlert>> getSosAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sos'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((alert) => SosAlert.fromJson(alert)).toList();
      } else {
        throw Exception('Failed to load SOS alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading SOS alerts: $e');
    }
  }

  // Get SOS alert by UUID
  Future<SosAlert> getSosAlert(String sosUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sos/$sosUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SosAlert.fromJson(data);
      } else {
        throw Exception('Failed to load SOS alert: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading SOS alert: $e');
    }
  }

// We don't implement create, update, delete since we're only viewing
}