class HouseMember {
  final int? houseMemberId;
  final String houseMemberUUID;
  final String userUUID;
  final String houseUUID;
  final String relationship;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userName; // We'll populate this from user data
  final String? userEmail; // We'll populate this from user data
  final String? houseName; // We'll populate this from house data
  final String? houseLocation; // We'll populate this from house data

  HouseMember({
    this.houseMemberId,
    required this.houseMemberUUID,
    required this.userUUID,
    required this.houseUUID,
    required this.relationship,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userEmail,
    this.houseName,
    this.houseLocation,
  });

  factory HouseMember.fromJson(Map<String, dynamic> json) {
    return HouseMember(
      houseMemberId: json['houseMemberId'],
      houseMemberUUID: json['houseMemberUUID'] ?? '',
      userUUID: json['userUUID'] ?? '',
      houseUUID: json['houseUUID'] ?? '',
      relationship: json['relationship'] ?? 'Member',
      status: json['status'] ?? 'ACTIVE',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      userName: json['userName'],
      userEmail: json['userEmail'],
      houseName: json['houseName'],
      houseLocation: json['houseLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'houseMemberId': houseMemberId,
      'houseMemberUUID': houseMemberUUID,
      'userUUID': userUUID,
      'houseUUID': houseUUID,
      'relationship': relationship,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'userName': userName,
      'userEmail': userEmail,
      'houseName': houseName,
      'houseLocation': houseLocation,
    };
  }

  HouseMember copyWith({
    String? relationship,
    String? status,
    DateTime? endDate,
  }) {
    return HouseMember(
      houseMemberId: houseMemberId,
      houseMemberUUID: houseMemberUUID,
      userUUID: userUUID,
      houseUUID: houseUUID,
      relationship: relationship ?? this.relationship,
      status: status ?? this.status,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userName: userName,
      userEmail: userEmail,
      houseName: houseName,
      houseLocation: houseLocation,
    );
  }

  // Helper method to check if membership is active
  bool get isActive => status == 'ACTIVE';

  // Helper method to check if membership is ended
  bool get isEnded => status == 'ENDED';

  // Helper method to format dates for display
  String get formattedStartDate {
    return startDate != null ? _formatDate(startDate!) : 'Not set';
  }

  String get formattedEndDate {
    return endDate != null ? _formatDate(endDate!) : 'Not ended';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}