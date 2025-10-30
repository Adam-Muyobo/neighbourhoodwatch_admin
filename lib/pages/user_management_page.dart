import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _isLoading = true;
  bool _isCreatingUser = false;
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _roleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _apiService.getAllUsers();
      setState(() => _users = users);
    } catch (e) {
      _showError('Failed to load users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<User> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.phoneNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesStatus = _statusFilter == 'ALL' ||
          user.status.toUpperCase() == _statusFilter;

      final matchesRole = _roleFilter == 'ALL' ||
          user.role.toUpperCase() == _roleFilter;

      return matchesSearch && matchesStatus && matchesRole;
    }).toList();
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(
        onSave: (name, email, phone, password, role) async {
          setState(() => _isCreatingUser = true);
          try {
            await _apiService.createUser(name, email, phone, password, role);
            _showSuccess('User created successfully');
            _loadUsers();
          } catch (e) {
            _showError('Failed to create user: $e');
          } finally {
            setState(() => _isCreatingUser = false);
          }
        },
      ),
    );
  }

  Future<void> _approveUser(User user) async {
    try {
      await _apiService.approveUser(user.userId.toString());
      _showSuccess('${user.name} approved successfully');
      _loadUsers();
    } catch (e) {
      _showError('Failed to approve user: $e');
    }
  }

  Future<void> _suspendUser(User user) async {
    final confirmed = await _showConfirmationDialog(
      'Suspend User',
      'Are you sure you want to suspend ${user.name}? They will not be able to login until reinstated.',
    );

    if (confirmed) {
      try {
        await _apiService.suspendUser(user.userId.toString());
        _showSuccess('${user.name} suspended successfully');
        _loadUsers();
      } catch (e) {
        _showError('Failed to suspend user: $e');
      }
    }
  }

  Future<void> _reinstateUser(User user) async {
    try {
      await _apiService.reinstateUser(user.userId.toString());
      _showSuccess('${user.name} reinstated successfully');
      _loadUsers();
    } catch (e) {
      _showError('Failed to reinstate user: $e');
    }
  }

  Future<void> _blockUser(User user) async {
    final confirmed = await _showConfirmationDialog(
      'Block User',
      'Are you sure you want to block ${user.name}? This will permanently prevent them from accessing the system.',
    );

    if (confirmed) {
      try {
        await _apiService.blockUser(user.userId.toString());
        _showSuccess('${user.name} blocked successfully');
        _loadUsers();
      } catch (e) {
        _showError('Failed to block user: $e');
      }
    }
  }

  Future<void> _activateUser(User user) async {
    try {
      // For users who are suspended or blocked, we can reinstate to activate
      await _apiService.reinstateUser(user.userId.toString());
      _showSuccess('${user.name} activated successfully');
      _loadUsers();
    } catch (e) {
      _showError('Failed to activate user: $e');
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await _showConfirmationDialog(
      'Delete User',
      'Are you sure you want to permanently delete ${user.name}? This action cannot be undone and all their data will be lost.',
    );

    if (confirmed) {
      try {
        await _apiService.deleteUser(user.userId.toString());
        _showSuccess('${user.name} deleted successfully');
        _loadUsers();
      } catch (e) {
        _showError('Failed to delete user: $e');
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showQuickActions(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionsSheet(
        user: user,
        onActionSelected: (action) async {
          Navigator.of(context).pop();
          switch (action) {
            case 'approve':
              await _approveUser(user);
              break;
            case 'suspend':
              await _suspendUser(user);
              break;
            case 'reinstate':
              await _reinstateUser(user);
              break;
            case 'block':
              await _blockUser(user);
              break;
            case 'activate':
              await _activateUser(user);
              break;
            case 'delete':
              await _deleteUser(user);
              break;
          }
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.orange;
      case 'SUSPENDED':
        return Colors.red;
      case 'BLOCKED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Colors.blue;
      case 'OFFICER':
        return Colors.purple;
      case 'MEMBER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Icons.check_circle;
      case 'INACTIVE':
        return Icons.pending;
      case 'SUSPENDED':
        return Icons.pause_circle;
      case 'BLOCKED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(status).withOpacity(0.1),//Border.all(color: Colors.grey.shade300)
      side: BorderSide(color: _getStatusColor(status)),
      avatar: Icon(_getStatusIcon(status), size: 16, color: _getStatusColor(status)),
    );
  }

  Widget _buildRoleChip(String role) {
    return Chip(
      label: Text(
        role,
        style: TextStyle(
          color: _getRoleColor(role),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getRoleColor(role).withOpacity(0.1),
      side: BorderSide(color: _getRoleColor(role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh Users',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users by name, email, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'ACTIVE',
                          'INACTIVE',
                          'SUSPENDED',
                          'BLOCKED'
                        ].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status == 'ALL' ? 'All Statuses' : status),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _statusFilter = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _roleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'ADMIN',
                          'OFFICER',
                          'MEMBER'
                        ].map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role == 'ALL' ? 'All Roles' : role),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _roleFilter = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredUsers.length} user${_filteredUsers.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _statusFilter != 'ALL' || _roleFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _statusFilter = 'ALL';
                        _roleFilter = 'ALL';
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return UserCard(
                    user: user,
                    statusChip: _buildStatusChip(user.status),
                    roleChip: _buildRoleChip(user.role),
                    onTap: () => _showQuickActions(user),
                    onStatusChange: (newStatus) {
                      switch (newStatus) {
                        case 'ACTIVE':
                          if (user.status.toUpperCase() == 'SUSPENDED') {
                            _reinstateUser(user);
                          } else {
                            _approveUser(user);
                          }
                          break;
                        case 'SUSPENDED':
                          _suspendUser(user);
                          break;
                        case 'BLOCKED':
                          _blockUser(user);
                          break;
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.blue[700],
        child: _isCreatingUser
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final User user;
  final Widget statusChip;
  final Widget roleChip;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const UserCard({
    super.key,
    required this.user,
    required this.statusChip,
    required this.roleChip,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: _getRoleColor(user.role),
                radius: 24,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (user.phoneNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.phoneNumber!,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [statusChip, roleChip],
                    ),
                  ],
                ),
              ),

              // Quick Actions
              PopupMenuButton<String>(
                onSelected: (action) => onStatusChange(action),
                itemBuilder: (context) {
                  final menuItems = <PopupMenuEntry<String>>[];
                  final currentStatus = user.status.toUpperCase();

                  // Status change options based on current status
                  if (currentStatus == 'INACTIVE') {
                    menuItems.add(const PopupMenuItem<String>(
                      value: 'ACTIVE',
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text('Approve User'),
                        subtitle: Text('Activate account'),
                      ),
                    ));
                  }

                  if (currentStatus == 'ACTIVE') {
                    menuItems.add(const PopupMenuItem<String>(
                      value: 'SUSPENDED',
                      child: ListTile(
                        leading: Icon(Icons.pause_circle, color: Colors.orange),
                        title: Text('Suspend User'),
                        subtitle: Text('Temporary restriction'),
                      ),
                    ));
                  }

                  if (currentStatus == 'SUSPENDED') {
                    menuItems.add(const PopupMenuItem<String>(
                      value: 'ACTIVE',
                      child: ListTile(
                        leading: Icon(Icons.play_circle, color: Colors.green),
                        title: Text('Reinstate User'),
                        subtitle: Text('Restore access'),
                      ),
                    ));
                  }

                  if (currentStatus != 'BLOCKED') {
                    menuItems.add(const PopupMenuItem<String>(
                      value: 'BLOCKED',
                      child: ListTile(
                        leading: Icon(Icons.block, color: Colors.red),
                        title: Text('Block User'),
                        subtitle: Text('Permanent restriction'),
                      ),
                    ));
                  }

                  return menuItems;
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Colors.blue;
      case 'OFFICER':
        return Colors.purple;
      case 'MEMBER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class QuickActionsSheet extends StatelessWidget {
  final User user;
  final Function(String) onActionSelected;

  const QuickActionsSheet({
    super.key,
    required this.user,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = user.status.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Manage ${user.name}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.email,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Status-based actions
          if (currentStatus == 'INACTIVE') ...[
            _buildActionButton(
              'Approve User',
              'Activate this user account',
              Icons.check_circle,
              Colors.green,
              'approve',
            ),
          ],

          if (currentStatus == 'ACTIVE') ...[
            _buildActionButton(
              'Suspend User',
              'Temporarily restrict access',
              Icons.pause_circle,
              Colors.orange,
              'suspend',
            ),
          ],

          if (currentStatus == 'SUSPENDED') ...[
            _buildActionButton(
              'Reinstate User',
              'Restore user access',
              Icons.play_circle,
              Colors.green,
              'reinstate',
            ),
          ],

          // Always available actions
          _buildActionButton(
            'Block User',
            'Permanently restrict access',
            Icons.block,
            Colors.red,
            'block',
          ),

          const SizedBox(height: 8),

          _buildActionButton(
            'Delete User',
            'Permanently remove user',
            Icons.delete,
            Colors.red,
            'delete',
            isDestructive: true,
          ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      String action, {
        bool isDestructive = false,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => onActionSelected(action),
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final Function(String, String, String, String, String) onSave;

  const UserFormDialog({super.key, required this.onSave});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'MEMBER';
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulate a small delay for better UX
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onSave(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text.trim(),
          _selectedRole,
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.person_add, color: Colors.blue),
          SizedBox(width: 12),
          Text(
            'Create New User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Selection
              const Text(
                'User Role',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: [
                      _buildDropdownItem('ADMIN', Icons.admin_panel_settings, Colors.blue),
                      _buildDropdownItem('OFFICER', Icons.security, Colors.purple),
                      _buildDropdownItem('MEMBER', Icons.person, Colors.green),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Enter full name',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'user@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+26771234567',
                  prefixText: '+267 ',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!value.startsWith('+267')) {
                    return 'Phone number must start with +267';
                  }
                  if (value.length < 13) {
                    return 'Please enter a complete phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Enter at least 6 characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitForm(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Password requirements
              Text(
                '• At least 6 characters\n• Include letters and numbers',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          child: const Text('CANCEL'),
        ),

        // Create Button
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: _isSubmitting
              ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('CREATE USER'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      scrollable: true,
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String role, IconData icon, Color color) {
    return DropdownMenuItem<String>(
      value: role,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(role),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}