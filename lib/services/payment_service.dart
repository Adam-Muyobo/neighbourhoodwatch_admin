import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/payment.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final String baseUrl = API_BASE_URL;

  // Get all payments
  Future<List<Payment>> getPayments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((payment) => Payment.fromJson(payment)).toList();
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading payments: $e');
    }
  }

  // Get payment by UUID
  Future<Payment> getPayment(String paymentUUID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentUUID'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to load payment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading payment: $e');
    }
  }

// We don't implement create, update, delete since we're only viewing
}