class Checkpoint {
  final int? checkpointId;
  final String checkpointUUID;
  final String code;
  final String name;
  final String type;
  final String? description;
  final String location;
  final String? houseUUID;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Checkpoint({
    this.checkpointId,
    required this.checkpointUUID,
    required this.code,
    required this.name,
    required this.type,
    this.description,
    required this.location,
    this.houseUUID,
    this.createdAt,
    this.updatedAt,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    return Checkpoint(
      checkpointId: json['checkpointId'],
      checkpointUUID: json['checkpointUUID'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'GATE',
      description: json['description'],
      location: json['location'] ?? '',
      houseUUID: json['houseUUID'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkpointId': checkpointId,
      'checkpointUUID': checkpointUUID,
      'code': code,
      'name': name,
      'type': type,
      'description': description,
      'location': location,
      'houseUUID': houseUUID,
    };
  }

  Checkpoint copyWith({
    String? code,
    String? name,
    String? type,
    String? description,
    String? location,
    String? houseUUID,
  }) {
    return Checkpoint(
      checkpointId: checkpointId,
      checkpointUUID: checkpointUUID,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      houseUUID: houseUUID ?? this.houseUUID,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}