import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';

/// Fixed bottom section of screen 2: Tarifa, Garantía, Total and «Pedir reserva».
class PriceSummaryBar extends StatelessWidget {
  const PriceSummaryBar({
    super.key,
    required this.fee,
    required this.deposit,
    required this.onRequest,
    this.submitting = false,
  });

  final num fee;
  final num deposit;

  /// Null keeps the button disabled (no slot chosen yet).
  final VoidCallback? onRequest;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = textTheme.bodyLarge?.copyWith(color: AppColors.textMuted);
    final value = textTheme.bodyLarge;
    final bold = textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    Widget line(String label, String amount, {bool total = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: total ? bold : muted)),
          Text(amount, style: total ? bold?.copyWith(fontSize: 18) : value),
        ],
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            line('Tarifa', money(fee)),
            line('Garantía', money(deposit)),
            line('Total', money(fee + deposit), total: true),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: submitting ? null : onRequest,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Pedir reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
