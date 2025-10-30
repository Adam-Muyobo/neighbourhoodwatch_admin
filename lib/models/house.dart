class House {
  final int? houseId;
  final String houseUUID;
  final String nameOrNumber;
  final String location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  House({
    this.houseId,
    required this.houseUUID,
    required this.nameOrNumber,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      houseId: json['houseId'],
      houseUUID: json['houseUUID'] ?? '',
      nameOrNumber: json['nameOrNumber'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'houseId': houseId,
      'houseUUID': houseUUID,
      'nameOrNumber': nameOrNumber,
      'location': location,
    };
  }

  House copyWith({
    String? nameOrNumber,
    String? location,
  }) {
    return House(
      houseId: houseId,
      houseUUID: houseUUID,
      nameOrNumber: nameOrNumber ?? this.nameOrNumber,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}