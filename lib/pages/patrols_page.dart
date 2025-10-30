import 'package:flutter/material.dart';
import '../services/patrol_service.dart';
import '../models/patrol.dart';

class PatrolsPage extends StatefulWidget {
  const PatrolsPage({super.key});

  @override
  State<PatrolsPage> createState() => _PatrolsPageState();
}

class _PatrolsPageState extends State<PatrolsPage> {
  final PatrolService _patrolService = PatrolService();
  List<Patrol> _patrols = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _anomalyFilter = 'ALL';
  String _timeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadPatrols();
  }

  Future<void> _loadPatrols() async {
    setState(() => _isLoading = true);
    try {
      final patrols = await _patrolService.getPatrols();
      setState(() => _patrols = patrols);
    } catch (e) {
      _showError('Failed to load patrols: $e');
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

  List<Patrol> get _filteredPatrols {
    return _patrols.where((patrol) {
      final matchesSearch =
          (patrol.officerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (patrol.checkpointName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (patrol.checkpointCode?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (patrol.comment?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesAnomaly = _anomalyFilter == 'ALL' ||
          (_anomalyFilter == 'ANOMALY' && patrol.anomalyFlag) ||
          (_anomalyFilter == 'NORMAL' && !patrol.anomalyFlag);

      // Time filtering
      final now = DateTime.now();
      final patrolDate = patrol.patrolDate;
      final matchesTime = _timeFilter == 'ALL' ||
          (_timeFilter == 'TODAY' &&
              patrolDate.year == now.year &&
              patrolDate.month == now.month &&
              patrolDate.day == now.day) ||
          (_timeFilter == 'WEEK' &&
              patrolDate.isAfter(now.subtract(const Duration(days: 7))));

      return matchesSearch && matchesAnomaly && matchesTime;
    }).toList();
  }

  Color _getAnomalyColor(bool hasAnomaly) {
    return hasAnomaly ? Colors.red : Colors.green;
  }

  IconData _getAnomalyIcon(bool hasAnomaly) {
    return hasAnomaly ? Icons.warning : Icons.check_circle;
  }

  String _getAnomalyText(bool hasAnomaly) {
    return hasAnomaly ? 'Anomaly Reported' : 'Normal Check';
  }

  Widget _buildAnomalyChip(bool hasAnomaly) {
    return Chip(
      label: Text(
        _getAnomalyText(hasAnomaly),
        style: TextStyle(
          color: _getAnomalyColor(hasAnomaly),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getAnomalyColor(hasAnomaly).withOpacity(0.1),
      side: BorderSide(color: _getAnomalyColor(hasAnomaly)),
      avatar: Icon(
        _getAnomalyIcon(hasAnomaly),
        size: 16,
        color: _getAnomalyColor(hasAnomaly),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Records'),
        backgroundColor: Colors.indigo[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatrols,
            tooltip: 'Refresh Patrols',
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
                    hintText: 'Search by officer, checkpoint, or comment...',
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
                        value: _anomalyFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'NORMAL',
                          'ANOMALY'
                        ].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status == 'ALL' ? 'All Statuses' : status),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _anomalyFilter = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _timeFilter,
                        decoration: const InputDecoration(
                          labelText: 'Time Period',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'TODAY',
                          'WEEK'
                        ].map((String period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(period == 'ALL' ? 'All Time' : period),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _timeFilter = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Patrol Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredPatrols.length} patrol${_filteredPatrols.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _anomalyFilter != 'ALL' || _timeFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _anomalyFilter = 'ALL';
                        _timeFilter = 'ALL';
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
                  value: _patrols.length.toString(),
                  color: Colors.blue,
                  icon: Icons.directions_walk,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Normal',
                  value: _patrols.where((p) => !p.anomalyFlag).length.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Anomalies',
                  value: _patrols.where((p) => p.anomalyFlag).length.toString(),
                  color: Colors.red,
                  icon: Icons.warning,
                ),
              ],
            ),
          ),

          // Patrols List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatrols.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_walk, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No patrol records found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patrol records will appear here when officers check in',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadPatrols,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPatrols.length,
                itemBuilder: (context, index) {
                  final patrol = _filteredPatrols[index];
                  return PatrolCard(
                    patrol: patrol,
                    anomalyChip: _buildAnomalyChip(patrol.anomalyFlag),
                  );
                },
              ),
            ),
          ),
        ],
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

class PatrolCard extends StatelessWidget {
  final Patrol patrol;
  final Widget anomalyChip;

  const PatrolCard({
    super.key,
    required this.patrol,
    required this.anomalyChip,
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
                // Patrol Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo[100]!),
                  ),
                  child: Icon(
                    Icons.directions_walk,
                    color: Colors.indigo[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Officer and Checkpoint Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patrol.officerName ?? 'Officer ${patrol.officerUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        patrol.checkpointName ?? 'Checkpoint ${patrol.checkpointUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (patrol.checkpointCode != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Code: ${patrol.checkpointCode!}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Anomaly Chip
                anomalyChip,
              ],
            ),

            const SizedBox(height: 12),

            // Date and Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  patrol.formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Coordinates (if available)
            if (patrol.hasCoordinates) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${patrol.latitude!.toStringAsFixed(4)}, ${patrol.longitude!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],

            // Comment (if available)
            if (patrol.comment != null && patrol.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Officer Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patrol.comment!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}