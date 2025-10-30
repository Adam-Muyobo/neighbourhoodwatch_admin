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
        actions: [
          // User profile menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                apiService.clearUserData();
                Navigator.pushReplacementNamed(context, '/');
              } else if (value == 'profile') {
                // TODO: Navigate to profile page
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // User Avatar
                    Container(
                      width: 60,
                      height: 60,
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
                        size: 30,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Text(
                              currentUser?.role ?? 'ADMIN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Indicator
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats Row
            Row(
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  value: '24', // You can make this dynamic later
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'Total Houses',
                  value: '18', // You can make this dynamic later
                  icon: Icons.house,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  title: 'Active Today',
                  value: '12', // You can make this dynamic later
                  icon: Icons.star,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Title
            const Text(
              'Management Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Buttons Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  // User Management
                  _buildDashboardCard(
                    title: "User Management",
                    subtitle: "Manage users and permissions",
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/user-management'),
                  ),

                  // House Management
                  _buildDashboardCard(
                    title: "House Management",
                    subtitle: "Manage monitored houses",
                    icon: Icons.house,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/house-management'),
                  ),

                  _buildDashboardCard(
                    title: "House Members",
                    subtitle: "Manage house assignments",
                    icon: Icons.person,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.pushNamed(context, '/house-members'),
                  ),

                  _buildDashboardCard(
                    title: "Checkpoint Management",
                    subtitle: "Manage security checkpoints",
                    icon: Icons.location_on,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/checkpoint-management'),
                  ),

                  _buildDashboardCard(
                    title: "Subscriptions",
                    subtitle: "View member subscriptions",
                    icon: Icons.subscriptions,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, '/subscriptions'),
                  ),

                  _buildDashboardCard(
                    title: "Patrol Records",
                    subtitle: "View officer patrol logs",
                    icon: Icons.directions_walk,
                    color: Colors.indigo,
                    onTap: () => Navigator.pushNamed(context, '/patrols'),
                  ),

                  _buildDashboardCard(
                    title: "Payments",
                    subtitle: "View payment transactions",
                    icon: Icons.payments,
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/payments'),
                  ),

                  _buildDashboardCard(
                    title: "SOS Alerts",
                    subtitle: "View emergency alerts",
                    icon: Icons.emergency,
                    color: Colors.red,
                    onTap: () => Navigator.pushNamed(context, '/sos-alerts'),
                  ),

                  // Reports
                  _buildDashboardCard(
                    title: "Reports",
                    subtitle: "View system reports",
                    icon: Icons.analytics,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reports - Coming soon'),
                        ),
                      );
                    },
                  ),

                  // System Settings
                  _buildDashboardCard(
                    title: "System Settings",
                    subtitle: "Configure system",
                    icon: Icons.settings,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('System Settings - Coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Neighbourhood Watch Admin System v1.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}