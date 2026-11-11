import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../data/standing_repository.dart';

/// Screen 4 · «Aún no puedes reservar» bottom sheet from the Figma.
Future<void> showNotUpToDateSheet(BuildContext context, Standing standing) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => NotUpToDateSheet(standing: standing),
  );
}

class NotUpToDateSheet extends StatelessWidget {
  const NotUpToDateSheet({super.key, required this.standing});

  final Standing standing;

  String get _message {
    final amount = money(standing.overdueAmount);
    final date = standing.oldestOverdueDate;
    final due = date == null
        ? ''
        : ', vencida el ${DateFormat('dd/MM').format(parseIsoDate(date))}';
    return 'Tienes una cuota pendiente de $amount$due. Ponte al día para reservar.';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.warningSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.warning,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aún no puedes reservar',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'El pago de cuotas estará disponible pronto.',
                    ),
                  ),
                );
              },
              child: const Text('Ver mi cuota'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ahora no'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
