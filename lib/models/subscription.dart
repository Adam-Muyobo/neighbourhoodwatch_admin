class Subscription {
  final int? subscriptionId;
  final String subscriptionUUID;
  final String memberUUID;
  final String type;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? memberName; // We'll populate this from the user data

  Subscription({
    this.subscriptionId,
    required this.subscriptionUUID,
    required this.memberUUID,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    this.updatedAt,
    this.memberName,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      subscriptionId: json['subscriptionId'],
      subscriptionUUID: json['subscriptionUUID'] ?? '',
      memberUUID: json['memberUUID'] ?? '',
      type: json['type'] ?? 'Monthly',
      status: json['status'] ?? 'INACTIVE',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      memberName: json['memberName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionId': subscriptionId,
      'subscriptionUUID': subscriptionUUID,
      'memberUUID': memberUUID,
      'type': type,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'memberName': memberName,
    };
  }

  // Helper method to check if subscription is active
  bool get isActive => status == 'ACTIVE';

  // Helper method to check if subscription is expired
  bool get isExpired => endDate.isBefore(DateTime.now());

  // Helper method to check days remaining
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}