import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../../../shared/widgets/area_icon.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/reservation_models.dart';

/// Chip for each state, with the Figma copy.
StatusChip statusChipFor(
  Reservation reservation,
) => switch (reservation.status) {
  ReservationStatus.pendingApproval => const StatusChip(
    label: 'Esperando aprobación',
    tone: ChipTone.warning,
  ),
  ReservationStatus.approved => StatusChip(
    label: reservation.paymentDeadline == null
        ? 'Aprobada'
        : 'Aprobada · paga antes de las ${buildingTime(reservation.paymentDeadline!)}',
    tone: ChipTone.info,
  ),
  ReservationStatus.confirmed => const StatusChip(
    label: 'Confirmada',
    tone: ChipTone.success,
  ),
  ReservationStatus.expired => const StatusChip(
    label: 'Vencida',
    tone: ChipTone.neutral,
  ),
  ReservationStatus.rejected => const StatusChip(
    label: 'Rechazada',
    tone: ChipTone.danger,
  ),
  ReservationStatus.refunded => const StatusChip(
    label: 'Devuelta',
    tone: ChipTone.neutral,
  ),
};

/// Top card of «Mi reserva»: area, status, date, slot and amounts.
class ReservationSummaryCard extends StatelessWidget {
  const ReservationSummaryCard({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AreaIcon(icon: reservation.areaIcon, size: 48),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.areaName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      reservation.buildingName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            statusChipFor(reservation),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _Line('Fecha', longDate(reservation.date)),
            _Line('Horario', reservation.slotLabel),
            _Line('Tarifa', money(reservation.fee)),
            _Line('Garantía', money(reservation.deposit)),
            _Line('Monto total', money(reservation.total), emphasis: true),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = emphasis
        ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)
        : textTheme.bodyLarge?.copyWith(color: AppColors.textMuted);
    final valueStyle = emphasis
        ? textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          )
        : textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(width: 12),
          // Wraps instead of overflowing with large system font sizes.
          Expanded(
            child: Text(value, style: valueStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
