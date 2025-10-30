import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final PaymentService _paymentService = PaymentService();
  List<Payment> _payments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _methodFilter = 'ALL';
  String _timeFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final payments = await _paymentService.getPayments();
      setState(() => _payments = payments);
    } catch (e) {
      _showError('Failed to load payments: $e');
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

  List<Payment> get _filteredPayments {
    return _payments.where((payment) {
      final matchesSearch =
          (payment.memberName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (payment.reference?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              payment.amount.toString().contains(_searchQuery) ||
              payment.subscriptionUUID.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesMethod = _methodFilter == 'ALL' || payment.paymentMethod == _methodFilter;

      // Time filtering
      final now = DateTime.now();
      final paymentDate = payment.paymentDate;
      final matchesTime = _timeFilter == 'ALL' ||
          (_timeFilter == 'TODAY' &&
              paymentDate.year == now.year &&
              paymentDate.month == now.month &&
              paymentDate.day == now.day) ||
          (_timeFilter == 'WEEK' &&
              paymentDate.isAfter(now.subtract(const Duration(days: 7)))) ||
          (_timeFilter == 'MONTH' &&
              paymentDate.isAfter(now.subtract(const Duration(days: 30))));

      return matchesSearch && matchesMethod && matchesTime;
    }).toList();
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'CASH':
        return Colors.green;
      case 'MOBILE_MONEY':
        return Colors.purple;
      case 'BANK_TRANSFER':
        return Colors.blue;
      case 'CARD':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'CASH':
        return Icons.money;
      case 'MOBILE_MONEY':
        return Icons.phone_android;
      case 'BANK_TRANSFER':
        return Icons.account_balance;
      case 'CARD':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  Widget _buildMethodChip(String method) {
    return Chip(
      label: Text(
        method.replaceAll('_', ' '),
        style: TextStyle(
          color: _getMethodColor(method),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getMethodColor(method).withOpacity(0.1),
      side: BorderSide(color: _getMethodColor(method)),
      avatar: Icon(
        _getMethodIcon(method),
        size: 16,
        color: _getMethodColor(method),
      ),
    );
  }

  double get _totalAmount {
    return _payments.fold(0, (sum, payment) => sum + payment.amount);
  }

  double get _filteredAmount {
    return _filteredPayments.fold(0, (sum, payment) => sum + payment.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Transactions'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayments,
            tooltip: 'Refresh Payments',
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
                    hintText: 'Search by member, reference, or amount...',
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
                        value: _methodFilter,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: [
                          'ALL',
                          'CASH',
                          'MOBILE_MONEY',
                          'BANK_TRANSFER',
                          'CARD'
                        ].map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method == 'ALL' ? 'All Methods' : method.replaceAll('_', ' ')),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _methodFilter = value!),
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
                          'WEEK',
                          'MONTH'
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

          // Payment Count and Amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_filteredPayments.length} payment${_filteredPayments.length != 1 ? 's' : ''} found',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Total: P${_filteredAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_searchQuery.isNotEmpty || _methodFilter != 'ALL' || _timeFilter != 'ALL')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _methodFilter = 'ALL';
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
                  value: 'P${_totalAmount.toStringAsFixed(2)}',
                  color: Colors.teal,
                  icon: Icons.attach_money,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Transactions',
                  value: _payments.length.toString(),
                  color: Colors.blue,
                  icon: Icons.list_alt,
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  title: 'Avg Payment',
                  value: _payments.isEmpty ? 'P0.00' : 'P${(_totalAmount / _payments.length).toStringAsFixed(2)}',
                  color: Colors.purple,
                  icon: Icons.trending_up,
                ),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPayments.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payments, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No payment records found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Payment records will appear here when members make payments',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadPayments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredPayments.length,
                itemBuilder: (context, index) {
                  final payment = _filteredPayments[index];
                  return PaymentCard(
                    payment: payment,
                    methodChip: _buildMethodChip(payment.paymentMethod),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final Widget methodChip;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.methodChip,
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
                // Payment Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal[100]!),
                  ),
                  child: Icon(
                    Icons.payments,
                    color: Colors.teal[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Member and Amount Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.memberName ?? 'Member ${payment.memberUUID?.substring(0, 8) ?? payment.subscriptionUUID.substring(0, 8)}...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment.formattedAmount,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Method Chip
                methodChip,
              ],
            ),

            const SizedBox(height: 12),

            // Date and Reference
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  payment.formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Reference Number (if available)
            if (payment.reference != null && payment.reference!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.receipt,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reference: ${payment.reference!}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Monospace',
                    ),
                  ),
                ],
              ),
            ],

            // Subscription ID
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.subscriptions,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Subscription: ${payment.subscriptionUUID.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}