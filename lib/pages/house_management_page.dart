import 'package:flutter/material.dart';
import '../services/house_service.dart';
import '../models/house.dart';

class HouseManagementPage extends StatefulWidget {
  const HouseManagementPage({super.key});

  @override
  State<HouseManagementPage> createState() => _HouseManagementPageState();
}

class _HouseManagementPageState extends State<HouseManagementPage> {
  final HouseService _houseService = HouseService();
  List<House> _houses = [];
  bool _isLoading = true;
  bool _isCreatingHouse = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    setState(() => _isLoading = true);
    try {
      final houses = await _houseService.getHouses();
      setState(() => _houses = houses);
    } catch (e) {
      _showError('Failed to load houses: $e');
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

  List<House> get _filteredHouses {
    return _houses.where((house) {
      return house.nameOrNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          house.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addHouse() {
    showDialog(
      context: context,
      builder: (context) => HouseFormDialog(
        onSave: (nameOrNumber, location) async {
          setState(() => _isCreatingHouse = true);
          try {
            await _houseService.createHouse(nameOrNumber, location);
            _showSuccess('House created successfully');
            _loadHouses();
          } catch (e) {
            _showError('Failed to create house: $e');
          } finally {
            setState(() => _isCreatingHouse = false);
          }
        },
      ),
    );
  }

  void _editHouse(House house) {
    showDialog(
      context: context,
      builder: (context) => HouseFormDialog(
        house: house,
        onSave: (nameOrNumber, location) async {
          try {
            await _houseService.updateHouse(house.houseUUID, nameOrNumber, location);
            _showSuccess('House updated successfully');
            _loadHouses();
          } catch (e) {
            _showError('Failed to update house: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteHouse(House house) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: Text('Are you sure you want to delete ${house.nameOrNumber}? This action cannot be undone.'),
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
        await _houseService.deleteHouse(house.houseUUID);
        _showSuccess('House deleted successfully');
        _loadHouses();
      } catch (e) {
        _showError('Failed to delete house: $e');
      }
    }
  }

  Color _getHouseColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Management'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHouses,
            tooltip: 'Refresh Houses',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search houses by name or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // House Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredHouses.length} house${_filteredHouses.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _searchQuery = ''),
                    child: const Text('Clear Search'),
                  ),
              ],
            ),
          ),

          // Houses List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHouses.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.house_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No houses found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first house to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadHouses,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredHouses.length,
                itemBuilder: (context, index) {
                  final house = _filteredHouses[index];
                  return HouseCard(
                    house: house,
                    color: _getHouseColor(index),
                    onEdit: () => _editHouse(house),
                    onDelete: () => _deleteHouse(house),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHouse,
        backgroundColor: Colors.green[700],
        child: _isCreatingHouse
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_home_work, color: Colors.white),
      ),
    );
  }
}

class HouseCard extends StatelessWidget {
  final House house;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HouseCard({
    super.key,
    required this.house,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // House Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.house_rounded,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // House Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.nameOrNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          house.location,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (house.createdAt != null)
                    Text(
                      'Added ${_formatDate(house.createdAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Edit House'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete House'),
                  ),
                ),
              ],
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}

class HouseFormDialog extends StatefulWidget {
  final House? house;
  final Function(String, String) onSave;

  const HouseFormDialog({
    super.key,
    this.house,
    required this.onSave,
  });

  @override
  State<HouseFormDialog> createState() => _HouseFormDialogState();
}

class _HouseFormDialogState extends State<HouseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.house != null) {
      _nameController.text = widget.house!.nameOrNumber;
      _locationController.text = widget.house!.location;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onSave(
          _nameController.text.trim(),
          _locationController.text.trim(),
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.house != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(isEditing ? Icons.edit : Icons.add_home_work, color: Colors.green),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit House' : 'Add New House',
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
              // House Name/Number
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'House Name/Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.house_outlined),
                  hintText: 'e.g., House 101, Plot 25, Villa Rose',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter house name or number';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'e.g., Central Street, Near Main Gate',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitForm(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  if (value.length < 3) {
                    return 'Location must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Help text
              Text(
                'Add houses that will be monitored in the neighbourhood',
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
            backgroundColor: Colors.green[700],
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
              : Text(isEditing ? 'UPDATE HOUSE' : 'CREATE HOUSE'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      scrollable: true,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}