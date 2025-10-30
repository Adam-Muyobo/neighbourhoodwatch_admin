class Patrol {
  final int? patrolId;
  final String patrolUUID;
  final String officerUUID;
  final String checkpointUUID;
  final String? comment;
  final bool anomalyFlag;
  final double? latitude;
  final double? longitude;
  final DateTime patrolDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? officerName; // We'll populate this from user data
  final String? checkpointName; // We'll populate this from checkpoint data
  final String? checkpointCode; // We'll populate this from checkpoint data

  Patrol({
    this.patrolId,
    required this.patrolUUID,
    required this.officerUUID,
    required this.checkpointUUID,
    this.comment,
    required this.anomalyFlag,
    this.latitude,
    this.longitude,
    required this.patrolDate,
    this.createdAt,
    this.updatedAt,
    this.officerName,
    this.checkpointName,
    this.checkpointCode,
  });

  factory Patrol.fromJson(Map<String, dynamic> json) {
    return Patrol(
      patrolId: json['patrolId'],
      patrolUUID: json['patrolUUID'] ?? '',
      officerUUID: json['officerUUID'] ?? '',
      checkpointUUID: json['checkpointUUID'] ?? '',
      comment: json['comment'],
      anomalyFlag: json['anomalyFlag'] ?? false,
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      patrolDate: DateTime.parse(json['patrolDate']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      officerName: json['officerName'],
      checkpointName: json['checkpointName'],
      checkpointCode: json['checkpointCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patrolId': patrolId,
      'patrolUUID': patrolUUID,
      'officerUUID': officerUUID,
      'checkpointUUID': checkpointUUID,
      'comment': comment,
      'anomalyFlag': anomalyFlag,
      'latitude': latitude,
      'longitude': longitude,
      'patrolDate': patrolDate.toIso8601String(),
      'officerName': officerName,
      'checkpointName': checkpointName,
      'checkpointCode': checkpointCode,
    };
  }

  // Helper method to check if patrol has coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  // Helper method to format date for display
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final patrolDay = DateTime(patrolDate.year, patrolDate.month, patrolDate.day);

    if (patrolDay == today) {
      return 'Today ${_formatTime(patrolDate)}';
    } else if (patrolDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${_formatTime(patrolDate)}';
    } else {
      return '${_formatDate(patrolDate)} ${_formatTime(patrolDate)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}