import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/house_member.dart';

class HouseMemberService {
  static final HouseMemberService _instance = HouseMemberService._internal();
  factory HouseMemberService() => _instance;
  HouseMemberService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all house members
  Future<List<HouseMember>> getHouseMembers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/house-members'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((member) => HouseMember.fromJson(member)).toList();
      } else {
        throw Exception('Failed to load house members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading house members: $e');
    }
  }

  // Get house member by UUID
  Future<HouseMember> getHouseMember(String houseMemberUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/house-members/$houseMemberUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HouseMember.fromJson(data);
      } else {
        throw Exception('Failed to load house member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading house member: $e');
    }
  }

  // Add house member
  Future<HouseMember> addHouseMember(String userUUID, String houseUUID, String relationship) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/house-members/$userUUID/$houseUUID?relationship=$relationship'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HouseMember.fromJson(data);
      } else {
        throw Exception('Failed to add house member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding house member: $e');
    }
  }

  // Update house member relationship
  Future<HouseMember> updateHouseMember(String houseMemberUUID, String relationship) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/house-members/$houseMemberUUID?relationship=$relationship'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HouseMember.fromJson(data);
      } else {
        throw Exception('Failed to update house member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating house member: $e');
    }
  }

  // End membership (soft delete)
  Future<HouseMember> endMembership(String houseMemberUUID) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/house-members/$houseMemberUUID/end'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return HouseMember.fromJson(data);
      } else {
        throw Exception('Failed to end membership: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending membership: $e');
    }
  }

  // Delete house member (permanent)
  Future<void> deleteHouseMember(String houseMemberUUID) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/house-members/$houseMemberUUID'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete house member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting house member: $e');
    }
  }
}