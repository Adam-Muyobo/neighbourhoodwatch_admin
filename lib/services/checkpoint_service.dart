import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/checkpoint.dart';

class CheckpointService {
  static final CheckpointService _instance = CheckpointService._internal();
  factory CheckpointService() => _instance;
  CheckpointService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all checkpoints
  Future<List<Checkpoint>> getCheckpoints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((checkpoint) => Checkpoint.fromJson(checkpoint)).toList();
      } else {
        throw Exception('Failed to load checkpoints: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading checkpoints: $e');
    }
  }

  // Get checkpoint by UUID
  Future<Checkpoint> getCheckpoint(String checkpointUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints/$checkpointUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Checkpoint.fromJson(data);
      } else {
        throw Exception('Failed to load checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading checkpoint: $e');
    }
  }

  // Get checkpoint by code
  Future<Checkpoint> getCheckpointByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/checkpoints/code/$code'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Checkpoint.fromJson(data);
      } else {
        throw Exception('Failed to load checkpoint by code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading checkpoint by code: $e');
    }
  }

  // Create checkpoint
  Future<Checkpoint> createCheckpoint({
    required String code,
    required String name,
    required String type,
    String? description,
    required String location,
    String? houseUUID,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'code': code,
        'name': name,
        'type': type,
        'location': location,
      };

      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      if (houseUUID != null && houseUUID.isNotEmpty) {
        body['houseUUID'] = houseUUID;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/checkpoints'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Checkpoint.fromJson(data);
      } else {
        throw Exception('Failed to create checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating checkpoint: $e');
    }
  }

  // Update checkpoint
  Future<Checkpoint> updateCheckpoint({
    required String checkpointUUID,
    String? code,
    String? name,
    String? type,
    String? description,
    String? location,
    String? houseUUID,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (code != null) body['code'] = code;
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (description != null) body['description'] = description;
      if (location != null) body['location'] = location;
      if (houseUUID != null) body['houseUUID'] = houseUUID;

      final response = await http.put(
        Uri.parse('$baseUrl/checkpoints/$checkpointUUID'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Checkpoint.fromJson(data);
      } else {
        throw Exception('Failed to update checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating checkpoint: $e');
    }
  }

  // Delete checkpoint
  Future<void> deleteCheckpoint(String checkpointUUID) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/checkpoints/$checkpointUUID'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete checkpoint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting checkpoint: $e');
    }
  }
}