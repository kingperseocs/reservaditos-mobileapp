import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../../../shared/widgets/area_icon.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/area_models.dart';

/// One area of screen 1: icon, fee, deposit, today's availability and «Reservar».
class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.area,
    required this.onReserve,
    this.busy = false,
  });

  final ResidentArea area;
  final VoidCallback onReserve;

  /// True while checking whether the resident can book.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyLarge?.copyWith(color: AppColors.textMuted);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AreaIcon(icon: area.icon),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tarifa ${money(area.fee)}', style: muted),
                      Text('Garantía ${money(area.deposit)}', style: muted),
                      const SizedBox(height: 8),
                      area.availableToday
                          ? const StatusChip(
                              label: 'Disponible hoy',
                              tone: ChipTone.success,
                            )
                          : const StatusChip(
                              label: 'Sin horarios hoy',
                              tone: ChipTone.neutral,
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy ? null : onReserve,
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Semantics(
                      label: 'Reservar ${area.name}',
                      excludeSemantics: true,
                      child: const Text('Reservar'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
