import 'package:flutter/material.dart';
import '../services/sos_service.dart';
import '../models/sos_alert.dart';

class SosAlertsPage extends StatefulWidget {
  const SosAlertsPage({super.key});

  @override
  State<SosAlertsPage> createState() => _SosAlertsPageState();
}

class _SosAlertsPageState extends State<SosAlertsPage> {
  final SosService _sosService = SosService();
  List<SosAlert> _alerts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _timeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final alerts = await _sosService.getSosAlerts();
      setState(() => _alerts = alerts);
    } catch (e) {
      _showError('Failed to load SOS alerts: $e');
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

  List<SosAlert> get _filteredAlerts {
    return _alerts.where((alert) {
      final matchesSearch =
          (alert.memberName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (alert.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (alert.checkpointName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              alert.memberUUID.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'ALL' || alert.status == _statusFilter;

      // Time filtering
      final now = DateTime.now();
      final alertDate = alert.alertDate;
      final matchesTime = _timeFilter == 'ALL' ||
          (_timeFilter == 'TODAY' &&
              alertDate.year == now.year &&
              alertDate.month == now.month &&
              alertDate.day == now.day) ||
          (_timeFilter == 'HOUR' &&
              alertDate.isAfter(now.subtract(const Duration(hours: 1)))) ||
          (_timeFilter == 'DAY' &&
              alertDate.isAfter(now.subtract(const Duration(days: 1))));

      return matchesSearch && matchesStatus && matchesTime;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.red;
      case 'RESOLVED':
        return Colors.green;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.warning;
      case 'RESOLVED':
        return Icons.check_circle;
      case 'IN_PROGRESS':
        return Icons.timelapse;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'URGENT';
      case 'RESOLVED':
        return 'RESOLVED';
      case 'IN_PROGRESS':
        return 'IN PROGRESS';
      case 'CANCELLED':
        return 'CANCELLED';
      default:
        return status;
    }
  }

  Widget _buildStatusChip(String status) {
    final isUrgent = status == 'PENDING';
    return Chip(
      label: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getStatusColor(status).withOpacity(0.1),
      side: BorderSide(color: _getStatusColor(status)),
      avatar: Icon(
        _getStatusIcon(status),
        size: 16,
        color: _getStatusColor(status),
      ),
      padding: isUrgent ? const EdgeInsets.symmetric(horizontal: 8) : null,
    );
  }

  int get _pendingCount => _alerts.where((alert) => alert.isUrgent).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Alerts'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
            tooltip: 'Refresh Alerts',
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
                    hintText: 'Search by member, description, or checkpoint...',
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
                          labelText: 'Alert Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'PENDING',
                          'IN_PROGRESS',
                          'RESOLVED',
                          'CANCELLED'
                        ].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status == 'ALL' ? 'All Statuses' : _getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _statusFilter = value!),
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
                          'HOUR',
                          'TODAY',
                          'DAY'
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

          // Alert Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredAlerts.length} alert${_filteredAlerts.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _statusFilter != 'ALL' || _timeFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _statusFilter = 'ALL';
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
                  value: _alerts.length.toString(),
                  color: Colors.blue,
                  icon: Icons.warning,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Urgent',
                  value: _pendingCount.toString(),
                  color: Colors.red,
                  icon: Icons.priority_high,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Resolved',
                  value: _alerts.where((a) => a.status == 'RESOLVED').length.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ),

          // Urgent Alert Banner (if any pending)
          if (_pendingCount > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  Icon(Icons.priority_high, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_pendingCount urgent alert${_pendingCount != 1 ? 's' : ''} require attention!',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Alerts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAlerts.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emergency, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No SOS alerts found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'SOS alerts will appear here when members trigger emergency alerts',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadAlerts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _filteredAlerts[index];
                  return SosAlertCard(
                    alert: alert,
                    statusChip: _buildStatusChip(alert.status),
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

class SosAlertCard extends StatelessWidget {
  final SosAlert alert;
  final Widget statusChip;

  const SosAlertCard({
    super.key,
    required this.alert,
    required this.statusChip,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = alert.isUrgent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUrgent ? 4 : 2,
      color: isUrgent ? Colors.red[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Alert Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isUrgent ? Colors.red[100] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isUrgent ? Colors.red : Colors.red[100]!,
                      width: isUrgent ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: isUrgent ? Colors.red : Colors.red[400],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Member and Time Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.memberName ?? 'Member ${alert.memberUUID.substring(0, 8)}...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUrgent ? Colors.red[700] : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alert.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: isUrgent ? FontWeight.bold : null,
                            ),
                          ),
                          if (!isUrgent) ...[
                            const SizedBox(width: 8),
                            Text(
                              alert.detailedDate,
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

                // Status Chip
                statusChip,
              ],
            ),

            const SizedBox(height: 12),

            // Checkpoint Info (if available)
            if (alert.checkpointName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    alert.checkpointName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (alert.checkpointCode != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        alert.checkpointCode!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Coordinates (if available)
            if (alert.hasCoordinates) ...[
              Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${alert.geoLat!.toStringAsFixed(4)}, ${alert.geoLng!.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Description (if available)
            if (alert.description != null && alert.description!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red[25] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUrgent ? Colors.red[100]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Description:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUrgent ? Colors.red[700] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUrgent ? Colors.red[800] : Colors.black87,
                        fontWeight: isUrgent ? FontWeight.w500 : null,
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