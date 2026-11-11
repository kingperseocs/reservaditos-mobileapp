import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../../../shared/widgets/area_icon.dart';
import '../data/reservation_models.dart';
import 'reservation_summary_card.dart';

/// Shortcut on screen 1 back to «Mi reserva» while a reservation is in
/// progress (not in the Figma: without it, leaving the screen loses the way
/// to check the status or pay).
class ActiveReservationBanner extends StatelessWidget {
  const ActiveReservationBanner({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  final Reservation reservation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AreaIcon(icon: reservation.areaIcon, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu reserva',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${reservation.areaName} · ${shortDayMonth(reservation.date)} · ${reservation.slotLabel}',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    statusChipFor(reservation),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
