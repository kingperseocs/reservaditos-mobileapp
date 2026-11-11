/// Mirrors `GET /v1/areas` (ResidentAreaDto).
class ResidentArea {
  const ResidentArea({
    required this.id,
    required this.name,
    required this.icon,
    required this.fee,
    required this.deposit,
    required this.total,
    required this.availableToday,
  });

  factory ResidentArea.fromJson(Map<String, dynamic> json) => ResidentArea(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    fee: json['fee'] as num,
    deposit: json['deposit'] as num,
    total: json['total'] as num,
    availableToday: json['availableToday'] as bool,
  );

  final String id;
  final String name;
  final String icon;
  final num fee;
  final num deposit;
  final num total;
  final bool availableToday;
}

/// Mirrors `GET /v1/residents/me` (ResidentProfileDto).
class ResidentProfile {
  const ResidentProfile({
    required this.id,
    required this.name,
    required this.apartment,
    required this.buildingName,
  });

  factory ResidentProfile.fromJson(Map<String, dynamic> json) =>
      ResidentProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        apartment: json['apartment'] as String?,
        buildingName: json['buildingName'] as String,
      );

  final String id;
  final String name;
  final String? apartment;
  final String buildingName;

  /// «Edificio Demo · Ana Pérez · Depto 502»
  String get subtitle => [
    buildingName,
    name,
    if (apartment != null) 'Depto $apartment',
  ].join(' · ');
}
