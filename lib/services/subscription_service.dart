import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/subscription.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all subscriptions
  Future<List<Subscription>> getSubscriptions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((subscription) => Subscription.fromJson(subscription)).toList();
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading subscriptions: $e');
    }
  }

  // Get subscription by UUID
  Future<Subscription> getSubscription(String subscriptionUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/$subscriptionUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Subscription.fromJson(data);
      } else {
        throw Exception('Failed to load subscription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading subscription: $e');
    }
  }

// We don't implement create, update, delete since we're only viewing
}