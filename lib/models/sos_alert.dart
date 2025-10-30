class SosAlert {
  final int? sosId;
  final String sosUUID;
  final String memberUUID;
  final String? description;
  final double? geoLat;
  final double? geoLng;
  final String? checkpointUUID;
  final String status;
  final DateTime alertDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? memberName; // We'll populate this from member data
  final String? checkpointName; // We'll populate this from checkpoint data
  final String? checkpointCode; // We'll populate this from checkpoint data

  SosAlert({
    this.sosId,
    required this.sosUUID,
    required this.memberUUID,
    this.description,
    this.geoLat,
    this.geoLng,
    this.checkpointUUID,
    required this.status,
    required this.alertDate,
    this.createdAt,
    this.updatedAt,
    this.memberName,
    this.checkpointName,
    this.checkpointCode,
  });

  factory SosAlert.fromJson(Map<String, dynamic> json) {
    return SosAlert(
      sosId: json['sosId'],
      sosUUID: json['sosUUID'] ?? '',
      memberUUID: json['memberUUID'] ?? '',
      description: json['description'],
      geoLat: json['geoLat'] != null ? double.parse(json['geoLat'].toString()) : null,
      geoLng: json['geoLng'] != null ? double.parse(json['geoLng'].toString()) : null,
      checkpointUUID: json['checkpointUUID'],
      status: json['status'] ?? 'PENDING',
      alertDate: DateTime.parse(json['alertDate']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      memberName: json['memberName'],
      checkpointName: json['checkpointName'],
      checkpointCode: json['checkpointCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sosId': sosId,
      'sosUUID': sosUUID,
      'memberUUID': memberUUID,
      'description': description,
      'geoLat': geoLat,
      'geoLng': geoLng,
      'checkpointUUID': checkpointUUID,
      'status': status,
      'alertDate': alertDate.toIso8601String(),
      'memberName': memberName,
      'checkpointName': checkpointName,
      'checkpointCode': checkpointCode,
    };
  }

  // Helper method to check if alert has coordinates
  bool get hasCoordinates => geoLat != null && geoLng != null;

  // Helper method to check if alert is urgent
  bool get isUrgent => status == 'PENDING';

  // Helper method to format date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(alertDate);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    }
  }

  String get detailedDate {
    return '${_formatDate(alertDate)} ${_formatTime(alertDate)}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}