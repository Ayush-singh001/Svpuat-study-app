class College {
  final String id;
  final String name;
  final String shortName;
  final String code;
  final String location;
  final String state;
  final String logoUrl;
  final String description;
  final bool isActive;

  College({
    required this.id,
    required this.name,
    this.shortName = '',
    required this.code,
    required this.location,
    this.state = 'Uttar Pradesh',
    this.logoUrl = '',
    required this.description,
    this.isActive = true,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? json['name'] ?? '',
      code: json['code'] ?? '',
      location: json['location'] ?? '',
      state: json['state'] ?? 'Uttar Pradesh',
      logoUrl: json['logoUrl'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'code': code,
      'location': location,
      'state': state,
      'logoUrl': logoUrl,
      'description': description,
      'isActive': isActive,
    };
  }

  College copyWith({
    String? id,
    String? name,
    String? shortName,
    String? code,
    String? location,
    String? state,
    String? logoUrl,
    String? description,
    bool? isActive,
  }) {
    return College(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      code: code ?? this.code,
      location: location ?? this.location,
      state: state ?? this.state,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
