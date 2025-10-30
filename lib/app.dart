import 'package:flutter/material.dart';
import 'pages/payments_page.dart';
import 'pages/checkpoint_management_page.dart';
import 'pages/house_member_management_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/patrols_page.dart';
import 'pages/register_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/sos_alert_page.dart';
import 'pages/subscription_page.dart';
import 'pages/user_management_page.dart';
import 'pages/house_management_page.dart';

class NeighbourhoodWatchApp extends StatelessWidget {
  const NeighbourhoodWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neighbourhood Watch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      // Add the checkpoint management route
      routes: {
        '/': (ctx) => const LandingPage(),
        '/login': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/admin': (ctx) => const AdminDashboardPage(),
        '/user-management': (ctx) => const UserManagementPage(),
        '/house-management': (ctx) => const HouseManagementPage(),
        '/house-members': (ctx) => const HouseMemberManagementPage(),
        '/checkpoint-management': (ctx) => const CheckpointManagementPage(),
        '/subscriptions': (ctx) => const SubscriptionsPage(),
        '/patrols': (ctx) => const PatrolsPage(),
        '/payments': (ctx) => const PaymentsPage(),
        '/sos-alerts': (ctx) => const SosAlertsPage(),
      },
    );
  }
}