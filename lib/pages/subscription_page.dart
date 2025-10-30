import 'package:flutter/material.dart';
import '../services/subscription_service.dart';
import '../models/subscription.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'ALL';
  String _typeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    setState(() => _isLoading = true);
    try {
      final subscriptions = await _subscriptionService.getSubscriptions();
      setState(() => _subscriptions = subscriptions);
    } catch (e) {
      _showError('Failed to load subscriptions: $e');
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

  List<Subscription> get _filteredSubscriptions {
    return _subscriptions.where((subscription) {
      final matchesSearch = subscription.memberUUID.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (subscription.memberName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          subscription.type.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'ALL' || subscription.status == _statusFilter;
      final matchesType = _typeFilter == 'ALL' || subscription.type == _typeFilter;

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'IN_ARREARS':
        return Colors.orange;
      case 'EXPIRED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Monthly':
        return Colors.blue;
      case 'Annually':
        return Colors.purple;
      case 'Quarterly':
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

  Widget _buildTypeChip(String type) {
    return Chip(
      label: Text(
        type,
        style: TextStyle(
          color: _getTypeColor(type),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getTypeColor(type).withOpacity(0.1),
      side: BorderSide(color: _getTypeColor(type)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDaysRemainingText(Subscription subscription) {
    if (subscription.isExpired) {
      return 'Expired ${_formatDate(subscription.endDate)}';
    } else {
      final days = subscription.daysRemaining;
      if (days == 0) return 'Expires today';
      if (days == 1) return '1 day remaining';
      return '$days days remaining';
    }
  }

  Color _getDaysRemainingColor(Subscription subscription) {
    if (subscription.isExpired) return Colors.red;
    if (subscription.daysRemaining <= 7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubscriptions,
            tooltip: 'Refresh Subscriptions',
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
                    hintText: 'Search by member, type...',
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
                          'IN_ARREARS',
                          'EXPIRED',
                          'CANCELLED'
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
                        value: _typeFilter,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'Monthly',
                          'Annually',
                          'Quarterly'
                        ].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type == 'ALL' ? 'All Types' : type),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _typeFilter = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Subscription Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredSubscriptions.length} subscription${_filteredSubscriptions.length != 1 ? 's' : ''} found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty || _statusFilter != 'ALL' || _typeFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _statusFilter = 'ALL';
                        _typeFilter = 'ALL';
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
                  title: 'Active',
                  value: _subscriptions.where((s) => s.isActive).length.toString(),
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Expired',
                  value: _subscriptions.where((s) => s.isExpired).length.toString(),
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Total',
                  value: _subscriptions.length.toString(),
                  color: Colors.blue,
                ),
              ],
            ),
          ),

          // Subscriptions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubscriptions.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subscriptions, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No subscriptions found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Subscriptions will appear here when created',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadSubscriptions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredSubscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = _filteredSubscriptions[index];
                  return SubscriptionCard(
                    subscription: subscription,
                    statusChip: _buildStatusChip(subscription.status),
                    typeChip: _buildTypeChip(subscription.type),
                    daysRemainingText: _getDaysRemainingText(subscription),
                    daysRemainingColor: _getDaysRemainingColor(subscription),
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
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
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

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final Widget statusChip;
  final Widget typeChip;
  final String daysRemainingText;
  final Color daysRemainingColor;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.statusChip,
    required this.typeChip,
    required this.daysRemainingText,
    required this.daysRemainingColor,
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
                // Subscription Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple[100]!),
                  ),
                  child: Icon(
                    Icons.subscriptions,
                    color: Colors.purple[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Member Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.memberName ?? 'Member ${subscription.memberUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Member ID: ${subscription.memberUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Chip
                statusChip,
              ],
            ),

            const SizedBox(height: 12),

            // Subscription Details
            Row(
              children: [
                // Type
                typeChip,
                const SizedBox(width: 8),

                // Dates
                Expanded(
                  child: Text(
                    '${_formatDate(subscription.startDate)} - ${_formatDate(subscription.endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Days Remaining
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: daysRemainingColor,
                ),
                const SizedBox(width: 4),
                Text(
                  daysRemainingText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: daysRemainingColor,
                  ),
                ),
              ],
            ),

            // Created Date (if available)
            if (subscription.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(subscription.createdAt!)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}