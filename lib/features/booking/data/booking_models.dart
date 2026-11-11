/// Mirrors `GET /v1/areas/:id/availability` days.
class DayAvailability {
  const DayAvailability({required this.date, required this.available});

  factory DayAvailability.fromJson(Map<String, dynamic> json) =>
      DayAvailability(
        date: json['date'] as String,
        available: json['available'] as bool,
      );

  /// yyyy-MM-dd
  final String date;
  final bool available;
}

enum SlotStatus { free, taken, unavailable }

/// Mirrors `GET /v1/areas/:id/slots` slots.
class SlotOption {
  const SlotOption({
    required this.start,
    required this.end,
    required this.label,
    required this.status,
  });

  factory SlotOption.fromJson(Map<String, dynamic> json) => SlotOption(
    start: json['start'] as String,
    end: json['end'] as String,
    label: json['label'] as String,
    status: switch (json['status']) {
      'FREE' => SlotStatus.free,
      'TAKEN' => SlotStatus.taken,
      _ => SlotStatus.unavailable,
    },
  );

  final String start;
  final String end;

  /// «12:00–15:00»
  final String label;
  final SlotStatus status;
}
