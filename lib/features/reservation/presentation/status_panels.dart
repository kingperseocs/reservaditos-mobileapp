import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../data/reservation_models.dart';

enum NoticeTone { warning, info, success, neutral, danger }

/// Colored box under the summary: «La administración revisa tu pedido», etc.
class NoticeBox extends StatelessWidget {
  const NoticeBox({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String message;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, border, accent) = switch (tone) {
      NoticeTone.warning => (
        AppColors.warningSoft,
        AppColors.warningBorder,
        AppColors.warningText,
      ),
      NoticeTone.info => (
        AppColors.primarySoft,
        AppColors.primaryBorder,
        AppColors.primaryText,
      ),
      NoticeTone.success => (
        AppColors.successSoft,
        AppColors.successBorder,
        AppColors.successText,
      ),
      NoticeTone.neutral => (
        AppColors.neutralSoft,
        AppColors.border,
        AppColors.text,
      ),
      NoticeTone.danger => (
        AppColors.dangerSoft,
        AppColors.dangerBorder,
        AppColors.danger,
      ),
    };
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: tone == NoticeTone.neutral ? AppColors.textMuted : accent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «Tiempo para pagar · Quedan 23 h 15 min», updated every 15 s.
class PaymentCountdown extends ConsumerStatefulWidget {
  const PaymentCountdown({super.key, required this.deadline});

  final DateTime deadline;

  @override
  ConsumerState<PaymentCountdown> createState() => _PaymentCountdownState();
}

class _PaymentCountdownState extends ConsumerState<PaymentCountdown> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 15),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider)();
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            const Icon(
              Icons.timer_outlined,
              color: AppColors.primary,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tiempo para pagar',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    remaining(widget.deadline.difference(now)),
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// «Comprobante» with the reservation code after paying.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({super.key, required this.reservation});

  final Reservation reservation;

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
              children: [
                const Icon(Icons.receipt_long_outlined, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Comprobante',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Código de reserva',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation.code ?? '—',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ReceiptLine(
              label: 'Pagado el',
              value: reservation.paidAt == null
                  ? '—'
                  : dateTime(reservation.paidAt!),
              labelStyle: muted,
              valueStyle: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            _ReceiptLine(
              label: 'Monto pagado',
              value: money(reservation.total),
              labelStyle: muted,
              valueStyle: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: labelStyle),
      const SizedBox(width: 12),
      Expanded(
        child: Text(value, style: valueStyle, textAlign: TextAlign.end),
      ),
    ],
  );
}
