enum ReservationStatus {
  pendingApproval,
  approved,
  confirmed,
  rejected,
  expired,
  refunded,
}

ReservationStatus _status(String value) => switch (value) {
  'PENDING_APPROVAL' => ReservationStatus.pendingApproval,
  'APPROVED' => ReservationStatus.approved,
  'CONFIRMED' => ReservationStatus.confirmed,
  'REJECTED' => ReservationStatus.rejected,
  'EXPIRED' => ReservationStatus.expired,
  'REFUNDED' => ReservationStatus.refunded,
  _ => throw FormatException('Unknown reservation status: $value'),
};

DateTime? _instant(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

/// Mirrors `GET /v1/reservations/:id` (ReservationDto).
class Reservation {
  const Reservation({
    required this.id,
    required this.status,
    required this.areaId,
    required this.areaName,
    required this.areaIcon,
    required this.buildingName,
    required this.date,
    required this.slotLabel,
    required this.fee,
    required this.deposit,
    required this.total,
    required this.requestedAt,
    this.paymentDeadline,
    this.paymentUrl,
    this.paidAt,
    this.code,
    this.rejectionReason,
    this.refundAmount,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>;
    final slot = json['slot'] as Map<String, dynamic>;
    return Reservation(
      id: json['id'] as String,
      status: _status(json['status'] as String),
      areaId: area['id'] as String,
      areaName: area['name'] as String,
      areaIcon: area['icon'] as String,
      buildingName: json['buildingName'] as String,
      date: json['date'] as String,
      slotLabel: slot['label'] as String,
      fee: json['fee'] as num,
      deposit: json['deposit'] as num,
      total: json['total'] as num,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      paymentDeadline: _instant(json['paymentDeadline']),
      paymentUrl: json['paymentUrl'] as String?,
      paidAt: _instant(json['paidAt']),
      code: json['code'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      refundAmount: json['refundAmount'] as num?,
    );
  }

  final String id;
  final ReservationStatus status;
  final String areaId;
  final String areaName;
  final String areaIcon;
  final String buildingName;

  /// yyyy-MM-dd
  final String date;

  /// «12:00–15:00»
  final String slotLabel;
  final num fee;
  final num deposit;
  final num total;
  final DateTime requestedAt;
  final DateTime? paymentDeadline;

  /// Only while APPROVED: the simulated payment link.
  final String? paymentUrl;
  final DateTime? paidAt;

  /// Receipt code, e.g. DEMO-4821.
  final String? code;
  final String? rejectionReason;
  final num? refundAmount;

  /// Token at the end of [paymentUrl] (…/v1/payments/{token}).
  String? get paymentToken => paymentUrl?.split('/').last;
}
