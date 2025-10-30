class Payment {
  final int? paymentId;
  final String paymentUUID;
  final String subscriptionUUID;
  final double amount;
  final String paymentMethod;
  final String? reference;
  final DateTime paymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? memberName; // We'll populate this from subscription data
  final String? memberUUID; // We'll populate this from subscription data

  Payment({
    this.paymentId,
    required this.paymentUUID,
    required this.subscriptionUUID,
    required this.amount,
    required this.paymentMethod,
    this.reference,
    required this.paymentDate,
    this.createdAt,
    this.updatedAt,
    this.memberName,
    this.memberUUID,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      paymentUUID: json['paymentUUID'] ?? '',
      subscriptionUUID: json['subscriptionUUID'] ?? '',
      amount: json['amount'] != null ? double.parse(json['amount'].toString()) : 0.0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      reference: json['reference'],
      paymentDate: DateTime.parse(json['paymentDate']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      memberName: json['memberName'],
      memberUUID: json['memberUUID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'paymentUUID': paymentUUID,
      'subscriptionUUID': subscriptionUUID,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'reference': reference,
      'paymentDate': paymentDate.toIso8601String(),
      'memberName': memberName,
      'memberUUID': memberUUID,
    };
  }

  // Helper method to format amount with currency
  String get formattedAmount => 'P${amount.toStringAsFixed(2)}';

  // Helper method to format date for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final paymentDay = DateTime(paymentDate.year, paymentDate.month, paymentDate.day);

    if (paymentDay == today) {
      return 'Today ${_formatTime(paymentDate)}';
    } else if (paymentDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${_formatTime(paymentDate)}';
    } else {
      return '${_formatDate(paymentDate)} ${_formatTime(paymentDate)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}