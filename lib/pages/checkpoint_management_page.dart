import 'package:flutter/material.dart';
import '../services/checkpoint_service.dart';
import '../services/house_service.dart';
import '../models/checkpoint.dart';
import '../models/house.dart';


class CheckpointManagementPage extends StatefulWidget {
  const CheckpointManagementPage({super.key});

  @override
  State<CheckpointManagementPage> createState() => _CheckpointManagementPageState();
}

class _CheckpointManagementPageState extends State<CheckpointManagementPage> {
  final CheckpointService _checkpointService = CheckpointService();
  final HouseService _houseService = HouseService();

  List<Checkpoint> _checkpoints = [];
  List<House> _houses = [];
  bool _isLoading = true;
  bool _isCreatingCheckpoint = false;
  String _searchQuery = '';
  String _typeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Use separate await calls for better type safety
      final checkpoints = await _checkpointService.getCheckpoints();
      final houses = await _houseService.getHouses();

      setState(() {
        _checkpoints = checkpoints;
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

  List<Checkpoint> get _filteredCheckpoints {
    return _checkpoints.where((checkpoint) {
      final matchesSearch = checkpoint.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          checkpoint.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          checkpoint.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _typeFilter == 'ALL' || checkpoint.type == _typeFilter;

      return matchesSearch && matchesType;
    }).toList();
  }

  void _addCheckpoint() {
    showDialog(
      context: context,
      builder: (context) => CheckpointFormDialog(
        houses: _houses,
        onSave: (code, name, type, description, location, houseUUID) async {
          setState(() => _isCreatingCheckpoint = true);
          try {
            await _checkpointService.createCheckpoint(
              code: code,
              name: name,
              type: type,
              description: description,
              location: location,
              houseUUID: houseUUID,
            );
            _showSuccess('Checkpoint created successfully');
            _loadData();
          } catch (e) {
            _showError('Failed to create checkpoint: $e');
          } finally {
            setState(() => _isCreatingCheckpoint = false);
          }
        },
      ),
    );
  }

  void _editCheckpoint(Checkpoint checkpoint) {
    showDialog(
      context: context,
      builder: (context) => CheckpointFormDialog(
        checkpoint: checkpoint,
        houses: _houses,
        onSave: (code, name, type, description, location, houseUUID) async {
          try {
            await _checkpointService.updateCheckpoint(
              checkpointUUID: checkpoint.checkpointUUID,
              code: code,
              name: name,
              type: type,
              description: description,
              location: location,
              houseUUID: houseUUID,
            );
            _showSuccess('Checkpoint updated successfully');
            _loadData();
          } catch (e) {
            _showError('Failed to update checkpoint: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteCheckpoint(Checkpoint checkpoint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checkpoint'),
        content: Text('Are you sure you want to delete checkpoint ${checkpoint.code} - ${checkpoint.name}? This action cannot be undone.'),
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
        await _checkpointService.deleteCheckpoint(checkpoint.checkpointUUID);
        _showSuccess('Checkpoint deleted successfully');
        _loadData();
      } catch (e) {
        _showError('Failed to delete checkpoint: $e');
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'GATE':
        return Colors.blue;
      case 'HOUSE':
        return Colors.green;
      case 'PATROL':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'GATE':
        return Icons.security;
      case 'HOUSE':
        return Icons.house;
      case 'PATROL':
        return Icons.directions_walk;
      default:
        return Icons.place;
    }
  }

  String? _getHouseName(String? houseUUID) {
    if (houseUUID == null) return null;
    final house = _houses.firstWhere(
          (h) => h.houseUUID == houseUUID,
      orElse: () => House(houseUUID: '', nameOrNumber: 'Unknown', location: ''),
    );
    return house.nameOrNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkpoint Management'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Checkpoints',
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
                    hintText: 'Search by code, name, or location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                // Type Filter
                DropdownButtonFormField<String>(
                  value: _typeFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    'ALL',
                    'GATE',
                    'HOUSE',
                    'PATROL'
                  ].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type == 'ALL' ? 'All Types' : type),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _typeFilter = value!),
                ),
              ],
            ),
          ),

          // Checkpoint Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredCheckpoints.length} checkpoint${_filteredCheckpoints.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _typeFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _typeFilter = 'ALL';
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),

          // Checkpoints List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCheckpoints.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.place, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No checkpoints found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first checkpoint to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredCheckpoints.length,
                itemBuilder: (context, index) {
                  final checkpoint = _filteredCheckpoints[index];
                  return CheckpointCard(
                    checkpoint: checkpoint,
                    houseName: _getHouseName(checkpoint.houseUUID),
                    typeColor: _getTypeColor(checkpoint.type),
                    typeIcon: _getTypeIcon(checkpoint.type),
                    onEdit: () => _editCheckpoint(checkpoint),
                    onDelete: () => _deleteCheckpoint(checkpoint),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCheckpoint,
        backgroundColor: Colors.orange[700],
        child: _isCreatingCheckpoint
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_location_alt, color: Colors.white),
      ),
    );
  }
}

// The rest of the classes (CheckpointCard, CheckpointFormDialog) remain the same...
class CheckpointCard extends StatelessWidget {
  final Checkpoint checkpoint;
  final String? houseName;
  final Color typeColor;
  final IconData typeIcon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CheckpointCard({
    super.key,
    required this.checkpoint,
    this.houseName,
    required this.typeColor,
    required this.typeIcon,
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
            // Checkpoint Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Icon(typeIcon, color: typeColor, size: 30),
            ),
            const SizedBox(width: 16),

            // Checkpoint Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code and Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(
                          checkpoint.code,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          checkpoint.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          checkpoint.location,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Type and House
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: typeColor),
                        ),
                        child: Text(
                          checkpoint.type,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (houseName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Text(
                            houseName!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Description (if available)
                  if (checkpoint.description != null && checkpoint.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      checkpoint.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                    title: Text('Edit Checkpoint'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete Checkpoint'),
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
}

class CheckpointFormDialog extends StatefulWidget {
  final Checkpoint? checkpoint;
  final List<House> houses;
  final Function(String, String, String, String?, String, String?) onSave;

  const CheckpointFormDialog({
    super.key,
    this.checkpoint,
    required this.houses,
    required this.onSave,
  });

  @override
  State<CheckpointFormDialog> createState() => _CheckpointFormDialogState();
}

class _CheckpointFormDialogState extends State<CheckpointFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedType = 'GATE';
  String? _selectedHouseUUID;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.checkpoint != null) {
      _codeController.text = widget.checkpoint!.code;
      _nameController.text = widget.checkpoint!.name;
      _selectedType = widget.checkpoint!.type;
      _descriptionController.text = widget.checkpoint!.description ?? '';
      _locationController.text = widget.checkpoint!.location;
      _selectedHouseUUID = widget.checkpoint!.houseUUID;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onSave(
          _codeController.text.trim(),
          _nameController.text.trim(),
          _selectedType,
          _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          _locationController.text.trim(),
          _selectedHouseUUID,
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.checkpoint != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(isEditing ? Icons.edit_location : Icons.add_location_alt, color: Colors.orange),
          const SizedBox(width: 12),
          Text(
            isEditing ? 'Edit Checkpoint' : 'Add New Checkpoint',
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
              // Code Field
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Checkpoint Code *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                  hintText: 'e.g., HOU001, GATE001',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter checkpoint code';
                  }
                  if (value.length < 3) {
                    return 'Code must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Checkpoint Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                  hintText: 'e.g., North Gate, Block A Checkpoint',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter checkpoint name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Selection
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Checkpoint Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'GATE',
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('GATE'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'HOUSE',
                    child: Row(
                      children: [
                        Icon(Icons.house, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('HOUSE'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'PATROL',
                    child: Row(
                      children: [
                        Icon(Icons.directions_walk, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text('PATROL'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // House Selection (only for HOUSE type or optional for others)
              DropdownButtonFormField<String?>(
                value: _selectedHouseUUID,
                decoration: const InputDecoration(
                  labelText: 'Associated House (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.house_outlined),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No House Associated'),
                  ),
                  ...widget.houses.map((house) {
                    return DropdownMenuItem(
                      value: house.houseUUID,
                      child: Text('${house.nameOrNumber} - ${house.location}'),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedHouseUUID = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'e.g., North Road, Block A Street',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Additional notes about this checkpoint...',
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
            backgroundColor: Colors.orange[700],
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
              : Text(isEditing ? 'UPDATE CHECKPOINT' : 'CREATE CHECKPOINT'),
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
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}