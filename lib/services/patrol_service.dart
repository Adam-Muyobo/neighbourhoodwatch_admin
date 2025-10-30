import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/patrol.dart';

class PatrolService {
  static final PatrolService _instance = PatrolService._internal();
  factory PatrolService() => _instance;
  PatrolService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all patrols
  Future<List<Patrol>> getPatrols() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrols'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((patrol) => Patrol.fromJson(patrol)).toList();
      } else {
        throw Exception('Failed to load patrols: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading patrols: $e');
    }
  }

  // Get patrol by UUID
  Future<Patrol> getPatrol(String patrolUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrols/$patrolUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Patrol.fromJson(data);
      } else {
        throw Exception('Failed to load patrol: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading patrol: $e');
    }
  }

// We don't implement create, update, delete since we're only viewing
}