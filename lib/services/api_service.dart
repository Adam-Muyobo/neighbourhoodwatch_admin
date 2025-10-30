import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = API_BASE_URL;
  String? _currentAdminId;

  set currentAdminId(String? adminId) => _currentAdminId = adminId;
  String? get currentAdminId => _currentAdminId;

  // Auth endpoints
  Future<dynamic> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<dynamic> registerAdmin(String name, String email, String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/admin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<dynamic> registerMember(String name, String email, String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/member'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Member registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Member registration error: $e');
    }
  }

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

  // User management endpoints
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

  Future<User> createUser(String name, String email, String phoneNumber, String password, String role) async {
    if (_currentAdminId == null) {
      throw Exception('Admin ID not set');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/admin/$_currentAdminId/create'),
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

  Future<void> approveUser(String userId) async {
    if (_currentAdminId == null) {
      throw Exception('Admin ID not set');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$_currentAdminId/approve/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User approval failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User approval error: $e');
    }
  }

  Future<void> suspendUser(String userId) async {
    if (_currentAdminId == null) {
      throw Exception('Admin ID not set');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$_currentAdminId/suspend/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User suspension failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User suspension error: $e');
    }
  }

  Future<void> reinstateUser(String userId) async {
    if (_currentAdminId == null) {
      throw Exception('Admin ID not set');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$_currentAdminId/reinstate/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User reinstatement failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User reinstatement error: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    if (_currentAdminId == null) {
      throw Exception('Admin ID not set');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$_currentAdminId/block/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('User blocking failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User blocking error: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    if (_currentAdminId == null) {
      throw Exception('Admin ID not set');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$_currentAdminId/delete/$userId'),
      );

      if (response.statusCode != 200) {
        throw Exception('User deletion failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User deletion error: $e');
    }
  }
}