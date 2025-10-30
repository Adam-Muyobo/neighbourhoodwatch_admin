import 'package:flutter/material.dart';
import '../services/house_member_service.dart';
import '../services/user_service.dart';
import '../services/house_service.dart';
import '../models/house_member.dart';
import '../models/user.dart';
import '../models/house.dart';

class HouseMemberManagementPage extends StatefulWidget {
  const HouseMemberManagementPage({super.key});

  @override
  State<HouseMemberManagementPage> createState() => _HouseMemberManagementPageState();
}

class _HouseMemberManagementPageState extends State<HouseMemberManagementPage> {
  final HouseMemberService _houseMemberService = HouseMemberService();
  final UserService _userService = UserService();
  final HouseService _houseService = HouseService();

  List<HouseMember> _houseMembers = [];
  List<User> _users = [];
  List<House> _houses = [];
  bool _isLoading = true;
  bool _isCreatingMember = false;
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _relationshipFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final houseMembers = await _houseMemberService.getHouseMembers();
      final users = await _userService.getAllUsers();
      final houses = await _houseService.getHouses();

      setState(() {
        _houseMembers = houseMembers;
        _users = users;
        _houses = houses;
      });
    } catch (e) {
      _showError('Failed to load data: $e');
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

  List<HouseMember> get _filteredHouseMembers {
    return _houseMembers.where((member) {
      final matchesSearch =
          (member.userName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (member.userEmail?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (member.houseName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (member.houseLocation?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesStatus = _statusFilter == 'ALL' || member.status == _statusFilter;
      final matchesRelationship = _relationshipFilter == 'ALL' || member.relationship == _relationshipFilter;

      return matchesSearch && matchesStatus && matchesRelationship;
    }).toList();
  }

  void _addHouseMember() {
    showDialog(
      context: context,
      builder: (context) => HouseMemberFormDialog(
        users: _users,
        houses: _houses,
        onSave: (userUUID, houseUUID, relationship) async {
          setState(() => _isCreatingMember = true);
          try {
            await _houseMemberService.addHouseMember(userUUID, houseUUID, relationship);
            _showSuccess('House member added successfully');
            _loadData();
          } catch (e) {
            _showError('Failed to add house member: $e');
          } finally {
            setState(() => _isCreatingMember = false);
          }
        },
      ),
    );
  }

  void _editHouseMember(HouseMember member) {
    showDialog(
      context: context,
      builder: (context) => HouseMemberFormDialog(
        member: member,
        users: _users,
        houses: _houses,
        onSave: (userUUID, houseUUID, relationship) async {
          try {
            await _houseMemberService.updateHouseMember(member.houseMemberUUID, relationship);
            _showSuccess('House member updated successfully');
            _loadData();
          } catch (e) {
            _showError('Failed to update house member: $e');
          }
        },
      ),
    );
  }

  Future<void> _endMembership(HouseMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Membership'),
        content: Text('Are you sure you want to end ${member.userName}\'s membership at ${member.houseName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('End Membership'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _houseMemberService.endMembership(member.houseMemberUUID);
        _showSuccess('Membership ended successfully');
        _loadData();
      } catch (e) {
        _showError('Failed to end membership: $e');
      }
    }
  }

  Future<void> _deleteHouseMember(HouseMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House Member'),
        content: Text('Are you sure you want to permanently delete ${member.userName}\'s membership at ${member.houseName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _houseMemberService.deleteHouseMember(member.houseMemberUUID);
        _showSuccess('House member deleted successfully');
        _loadData();
      } catch (e) {
        _showError('Failed to delete house member: $e');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'ENDED':
        return Colors.grey;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship.toUpperCase()) {
      case 'OWNER':
        return Colors.purple;
      case 'TENANT':
        return Colors.blue;
      case 'FAMILY':
        return Colors.green;
      case 'MEMBER':
        return Colors.teal;
      default:
        return Colors.grey;
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
      backgroundColor: _getStatusColor(status).withOpacity(0.1),
      side: BorderSide(color: _getStatusColor(status)),
    );
  }

  Widget _buildRelationshipChip(String relationship) {
    return Chip(
      label: Text(
        relationship,
        style: TextStyle(
          color: _getRelationshipColor(relationship),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getRelationshipColor(relationship).withOpacity(0.1),
      side: BorderSide(color: _getRelationshipColor(relationship)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Members'),
        backgroundColor: Colors.deepPurple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Members',
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
                    hintText: 'Search by member, house, or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'ACTIVE',
                          'ENDED'
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
                        value: _relationshipFilter,
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'Owner',
                          'Tenant',
                          'Family',
                          'Member'
                        ].map((String relationship) {
                          return DropdownMenuItem<String>(
                            value: relationship,
                            child: Text(relationship == 'ALL' ? 'All Relationships' : relationship),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _relationshipFilter = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Member Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredHouseMembers.length} member${_filteredHouseMembers.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _statusFilter != 'ALL' || _relationshipFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _statusFilter = 'ALL';
                        _relationshipFilter = 'ALL';
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Statistics Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _buildStatCard(
                  title: 'Total',
                  value: _houseMembers.length.toString(),
                  color: Colors.blue,
                  icon: Icons.people,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Active',
                  value: _houseMembers.where((m) => m.isActive).length.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Ended',
                  value: _houseMembers.where((m) => m.isEnded).length.toString(),
                  color: Colors.grey,
                  icon: Icons.cancel,
                ),
              ],
            ),
          ),

          // Members List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHouseMembers.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No house members found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add members to houses to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredHouseMembers.length,
                itemBuilder: (context, index) {
                  final member = _filteredHouseMembers[index];
                  return HouseMemberCard(
                    member: member,
                    statusChip: _buildStatusChip(member.status),
                    relationshipChip: _buildRelationshipChip(member.relationship),
                    onEdit: () => _editHouseMember(member),
                    onEndMembership: () => _endMembership(member),
                    onDelete: () => _deleteHouseMember(member),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHouseMember,
        backgroundColor: Colors.deepPurple[700],
        child: _isCreatingMember
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HouseMemberCard extends StatelessWidget {
  final HouseMember member;
  final Widget statusChip;
  final Widget relationshipChip;
  final VoidCallback onEdit;
  final VoidCallback onEndMembership;
  final VoidCallback onDelete;

  const HouseMemberCard({
    super.key,
    required this.member,
    required this.statusChip,
    required this.relationshipChip,
    required this.onEdit,
    required this.onEndMembership,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Member Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.deepPurple[100]!),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.deepPurple[700],
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),

                // Member and House Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.userName ?? 'User ${member.userUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.userEmail ?? 'No email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.houseName ?? 'House ${member.houseUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (member.houseLocation != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          member.houseLocation!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status Chip
                statusChip,
              ],
            ),

            const SizedBox(height: 12),

            // Relationship and Actions
            Row(
              children: [
                relationshipChip,
                const Spacer(),

                // Actions
                PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'end':
                        onEndMembership();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    final menuItems = <PopupMenuEntry<String>>[];

                    if (member.isActive) {
                      menuItems.add(const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Edit Relationship'),
                        ),
                      ));

                      menuItems.add(const PopupMenuItem<String>(
                        value: 'end',
                        child: ListTile(
                          leading: Icon(Icons.cancel, color: Colors.orange),
                          title: Text('End Membership'),
                        ),
                      ));
                    }

                    menuItems.add(const PopupMenuDivider());

                    menuItems.add(const PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Permanently'),
                      ),
                    ));

                    return menuItems;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.more_vert, color: Colors.grey),
                  ),
                ),
              ],
            ),

            // Dates
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Started: ${member.formattedStartDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (member.isEnded) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Ended: ${member.formattedEndDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HouseMemberFormDialog extends StatefulWidget {
  final HouseMember? member;
  final List<User> users;
  final List<House> houses;
  final Function(String, String, String) onSave;

  const HouseMemberFormDialog({
    super.key,
    this.member,
    required this.users,
    required this.houses,
    required this.onSave,
  });

  @override
  State<HouseMemberFormDialog> createState() => _HouseMemberFormDialogState();
}

class _HouseMemberFormDialogState extends State<HouseMemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserUUID;
  String? _selectedHouseUUID;
  String _selectedRelationship = 'Member';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _selectedUserUUID = widget.member!.userUUID;
      _selectedHouseUUID = widget.member!.houseUUID;
      _selectedRelationship = widget.member!.relationship;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserUUID == null || _selectedHouseUUID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both user and house'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onSave(
          _selectedUserUUID!,
          _selectedHouseUUID!,
          _selectedRelationship,
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;
    final availableUsers = widget.users.where((user) => user.role == 'MEMBER' || user.role == 'OFFICER').toList();

    return AlertDialog(
      title: Row(
        children: [
          Icon(isEditing ? Icons.edit : Icons.person_add, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit House Member' : 'Add House Member',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
              // User Selection
              DropdownButtonFormField<String?>(
                value: _selectedUserUUID,
                decoration: const InputDecoration(
                  labelText: 'Select User *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select a user...'),
                  ),
                  ...availableUsers.map((user) {
                    return DropdownMenuItem(
                      value: user.userUUID,
                      child: Text('${user.name} (${user.email})'),
                    );
                  }).toList(),
                ],
                onChanged: isEditing ? null : (value) {
                  setState(() {
                    _selectedUserUUID = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a user';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // House Selection
              DropdownButtonFormField<String?>(
                value: _selectedHouseUUID,
                decoration: const InputDecoration(
                  labelText: 'Select House *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.house),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Select a house...'),
                  ),
                  ...widget.houses.map((house) {
                    return DropdownMenuItem(
                      value: house.houseUUID,
                      child: Text('${house.nameOrNumber} - ${house.location}'),
                    );
                  }).toList(),
                ],
                onChanged: isEditing ? null : (value) {
                  setState(() {
                    _selectedHouseUUID = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a house';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Relationship Selection
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                items: [
                  'Owner',
                  'Tenant',
                  'Family',
                  'Member'
                ].map((String relationship) {
                  return DropdownMenuItem(
                    value: relationship,
                    child: Text(relationship),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelationship = value!;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Help text
              Text(
                isEditing
                    ? 'Update the relationship for this house member'
                    : 'Assign a user to a house with a specific relationship',
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

        // Save Button
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[700],
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
              : Text(isEditing ? 'UPDATE MEMBER' : 'ADD MEMBER'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      scrollable: true,
    );
  }
}