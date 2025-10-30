import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/house.dart';

class HouseService {
  static final HouseService _instance = HouseService._internal();
  factory HouseService() => _instance;
  HouseService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all houses
  Future<List<House>> getHouses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/houses'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((house) => House.fromJson(house)).toList();
      } else {
        throw Exception('Failed to load houses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading houses: $e');
    }
  }

  // Get house by UUID
  Future<House> getHouse(String houseUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/houses/$houseUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return House.fromJson(data);
      } else {
        throw Exception('Failed to load house: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading house: $e');
    }
  }

  // Create house
  Future<House> createHouse(String nameOrNumber, String location) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/houses'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nameOrNumber': nameOrNumber,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return House.fromJson(data);
      } else {
        throw Exception('Failed to create house: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating house: $e');
    }
  }

  // Update house
  Future<House> updateHouse(String houseUUID, String nameOrNumber, String location) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/houses/$houseUUID'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nameOrNumber': nameOrNumber,
          'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return House.fromJson(data);
      } else {
        throw Exception('Failed to update house: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating house: $e');
    }
  }

  // Delete house
  Future<void> deleteHouse(String houseUUID) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/houses/$houseUUID'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete house: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting house: $e');
    }
  }
}