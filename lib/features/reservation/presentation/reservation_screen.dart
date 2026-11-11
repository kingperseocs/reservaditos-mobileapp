import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../application/reservation_controller.dart';
import '../data/reservation_models.dart';
import 'reservation_summary_card.dart';
import 'status_panels.dart';

/// Screen 3 · Mi reserva: status in real time and the simulated payment.
class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  bool _paying = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      await ref.read(reservationProvider(widget.reservationId).notifier).pay();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep «Tu reserva» on screen 1 in sync when the status changes (approved, paid…).
    ref.listen(
      reservationProvider(widget.reservationId)
          .select((state) => state.value?.status),
      (previous, next) {
        if (previous != null && previous != next) {
          ref.invalidate(activeReservationProvider);
        }
      },
    );

    final state = ref.watch(reservationProvider(widget.reservationId));
    final reservation = state.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi reserva')),
      body: switch (state) {
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(reservationProvider(widget.reservationId).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              ReservationSummaryCard(reservation: value),
              const SizedBox(height: 16),
              ..._statusSection(value),
            ],
          ),
        ),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () =>
              ref.invalidate(reservationProvider(widget.reservationId)),
        ),
        _ => const LoadingView(),
      },
      bottomNavigationBar: reservation?.status == ReservationStatus.approved
          ? _PayBar(amount: reservation!.total, paying: _paying, onPay: _pay)
          : null,
    );
  }

  List<Widget> _statusSection(
    Reservation reservation,
  ) => switch (reservation.status) {
    ReservationStatus.pendingApproval => const [
      NoticeBox(
        icon: Icons.hourglass_empty,
        title: 'La administración revisa tu pedido',
        message: 'Te avisaremos cuando responda.',
        tone: NoticeTone.warning,
      ),
    ],
    ReservationStatus.approved => [
      NoticeBox(
        icon: Icons.timer_outlined,
        title: reservation.paymentDeadline == null
            ? 'Tu reserva fue aprobada'
            : 'Paga antes de las ${timeAndDayMonth(reservation.paymentDeadline!)}',
        message: 'Si no pagas a tiempo, el horario se libera.',
        tone: NoticeTone.info,
      ),
      if (reservation.paymentDeadline != null) ...[
        const SizedBox(height: 16),
        PaymentCountdown(deadline: reservation.paymentDeadline!),
      ],
    ],
    ReservationStatus.confirmed => [
      NoticeBox(
        icon: Icons.check_circle_outline,
        title: 'Reserva confirmada',
        message: 'Tu pago de ${money(reservation.total)} se registró.',
        tone: NoticeTone.success,
      ),
      const SizedBox(height: 16),
      ReceiptCard(reservation: reservation),
    ],
    ReservationStatus.expired => const [
      NoticeBox(
        icon: Icons.schedule,
        title: 'No se pagó a tiempo',
        message: 'El horario se liberó.',
        tone: NoticeTone.neutral,
      ),
    ],
    ReservationStatus.rejected => [
      NoticeBox(
        icon: Icons.cancel_outlined,
        title: 'Motivo del rechazo',
        message:
            reservation.rejectionReason ??
            'La administración rechazó el pedido.',
        tone: NoticeTone.danger,
      ),
    ],
    ReservationStatus.refunded => [
      NoticeBox(
        icon: Icons.currency_exchange,
        title:
            'Te devolvimos ${money(reservation.refundAmount ?? reservation.total)}',
        message:
            reservation.rejectionReason ??
            'El área se suspendió para esa fecha.',
        tone: NoticeTone.neutral,
      ),
    ],
  };
}

/// Fixed «Pagar S/ 150» button while the payment window is open.
class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.amount,
    required this.paying,
    required this.onPay,
  });

  final num amount;
  final bool paying;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: paying ? null : onPay,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: paying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('Pagar ${money(amount)}'),
        ),
      ),
    );
  }
}
