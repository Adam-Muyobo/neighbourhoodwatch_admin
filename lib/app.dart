import 'package:flutter/material.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin_dashboard_page.dart';
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
      routes: {
        '/': (ctx) => const LandingPage(),
        '/login': (ctx) => const LoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/admin': (ctx) => const AdminDashboardPage(),
        '/user-management': (ctx) => const UserManagementPage(),
        '/house-management': (ctx) => const HouseManagementPage(),
      },
    );
  }
}