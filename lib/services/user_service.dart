import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

  // Get user by ID
  Future<User> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading user: $e');
    }
  }

  // Create user (admin only)
  Future<User> createUser(String name, String email, String phoneNumber, String password, String role, String adminId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/admin/$adminId/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('User creation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User creation error: $e');
    }
  }

  // Approve user
  Future<void> approveUser(String userId, String adminId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$adminId/approve/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User approval failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User approval error: $e');
    }
  }

  // Suspend user
  Future<void> suspendUser(String userId, String adminId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$adminId/suspend/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User suspension failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User suspension error: $e');
    }
  }

  // Reinstate user
  Future<void> reinstateUser(String userId, String adminId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$adminId/reinstate/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User reinstatement failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User reinstatement error: $e');
    }
  }

  // Block user
  Future<void> blockUser(String userId, String adminId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$adminId/block/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User blocking failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User blocking error: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId, String adminId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$adminId/delete/$userId'),
      );

      if (response.statusCode != 200) {
        throw Exception('User deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User deletion error: $e');
    }
  }

  // Check if user exists by email
  Future<User?> checkUser(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/check/$email'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}