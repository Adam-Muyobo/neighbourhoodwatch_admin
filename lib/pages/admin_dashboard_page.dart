import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    final User? currentUser = apiService.currentUser;
    final String userName = currentUser?.name ?? 'Administrator';
    final String userEmail = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // User profile menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                apiService.clearUserData();
                Navigator.pushReplacementNamed(context, '/');
              } else if (value == 'profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile page - Coming soon'),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text('Profile: $userName'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isLargeScreen = constraints.maxWidth > 1200;
          final bool isMediumScreen = constraints.maxWidth > 768;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 40.0 : 20.0,
              vertical: 20.0,
            ),
            constraints: const BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header - Responsive layout
                  _buildWelcomeHeader(context, userName, userEmail, currentUser, isLargeScreen),
                  const SizedBox(height: 32),

                  // Quick Stats - Responsive grid
                  _buildStatsSection(isLargeScreen, isMediumScreen),
                  const SizedBox(height: 32),

                  // Section Title
                  Padding(
                    padding: EdgeInsets.only(
                      left: isLargeScreen ? 8.0 : 0,
                      bottom: 16,
                    ),
                    child: Text(
                      'Management Tools',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 24 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  // Management Tools Grid - Fully responsive
                  _buildManagementToolsGrid(context, isLargeScreen, isMediumScreen),

                  // Footer
                  const SizedBox(height: 32),
                  const Center(
                    child: Text(
                      "Neighbourhood Watch Admin System v1.0",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String userName, String userEmail, User? currentUser, bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 32.0 : 20.0),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: isLargeScreen ? 80 : 60,
              height: isLargeScreen ? 80 : 60,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue[300]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                size: isLargeScreen ? 40 : 30,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(width: isLargeScreen ? 24 : 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: isLargeScreen ? 28 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  if (userEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      currentUser?.role ?? 'ADMIN',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Indicator - Only show on large screens
            if (isLargeScreen) ...[
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administrator',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isLargeScreen, bool isMediumScreen) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 3 : 2),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isLargeScreen ? 1.8 : 1.5,
      children: [
        _buildStatCard(
          title: 'Total Users',
          value: '24',
          icon: Icons.people_alt,
          color: Colors.blue,
          isLargeScreen: isLargeScreen,
        ),
        _buildStatCard(
          title: 'Total Houses',
          value: '18',
          icon: Icons.house,
          color: Colors.green,
          isLargeScreen: isLargeScreen,
        ),
        _buildStatCard(
          title: 'Active Today',
          value: '12',
          icon: Icons.star,
          color: Colors.orange,
          isLargeScreen: isLargeScreen,
        ),
        _buildStatCard(
          title: 'Pending Tasks',
          value: '5',
          icon: Icons.pending_actions,
          color: Colors.purple,
          isLargeScreen: isLargeScreen,
        ),
      ],
    );
  }

  Widget _buildManagementToolsGrid(BuildContext context, bool isLargeScreen, bool isMediumScreen) {
    final tools = [
      _ToolItem(
        title: "User Management",
        subtitle: "Manage users and permissions",
        icon: Icons.people,
        color: Colors.blue,
        route: '/user-management',
      ),
      _ToolItem(
        title: "House Management",
        subtitle: "Manage monitored houses",
        icon: Icons.house,
        color: Colors.green,
        route: '/house-management',
      ),
      _ToolItem(
        title: "House Members",
        subtitle: "Manage house assignments",
        icon: Icons.person_add,
        color: Colors.deepPurple,
        route: '/house-members',
      ),
      _ToolItem(
        title: "Checkpoint Management",
        subtitle: "Manage security checkpoints",
        icon: Icons.location_on,
        color: Colors.orange,
        route: '/checkpoint-management',
      ),
      _ToolItem(
        title: "Subscriptions",
        subtitle: "View member subscriptions",
        icon: Icons.subscriptions,
        color: Colors.purple,
        route: '/subscriptions',
      ),
      _ToolItem(
        title: "Patrol Records",
        subtitle: "View officer patrol logs",
        icon: Icons.directions_walk,
        color: Colors.indigo,
        route: '/patrols',
      ),
      _ToolItem(
        title: "Payments",
        subtitle: "View payment transactions",
        icon: Icons.payments,
        color: Colors.teal,
        route: '/payments',
      ),
      _ToolItem(
        title: "SOS Alerts",
        subtitle: "View emergency alerts",
        icon: Icons.emergency,
        color: Colors.red,
        route: '/sos-alerts',
      ),
      _ToolItem(
        title: "Reports",
        subtitle: "View system reports",
        icon: Icons.analytics,
        color: Colors.orange,
        route: null,
        comingSoon: true,
      ),
      _ToolItem(
        title: "System Settings",
        subtitle: "Configure system",
        icon: Icons.settings,
        color: Colors.purple,
        route: null,
        comingSoon: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 3 : 2),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isLargeScreen ? 1.1 : 1.2,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        return _buildDashboardCard(
          context: context, // Pass context here
          tool: tools[index],
          isLargeScreen: isLargeScreen,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLargeScreen,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: isLargeScreen ? 28 : 20, color: color),
                ),
                if (isLargeScreen) ...[
                  Icon(Icons.trending_up, color: Colors.green, size: 20),
                ],
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 28 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fixed: Added BuildContext parameter
  Widget _buildDashboardCard({
    required BuildContext context, // Add context parameter
    required _ToolItem tool,
    required bool isLargeScreen,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: tool.route != null ? () => Navigator.pushNamed(context, tool.route!) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tool.color.withOpacity(0.08),
                tool.color.withOpacity(0.15),
              ],
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tool.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tool.icon,
                        size: isLargeScreen ? 36 : 28,
                        color: tool.color
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tool.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 18 : 16,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool.subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tool.comingSoon) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (tool.route != null) ...[
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: tool.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: tool.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? route;
  final bool comingSoon;

  _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.route,
    this.comingSoon = false,
  });
}