import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/clock.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';
import '../../../shared/widgets/async_states.dart';
import '../../areas/data/area_models.dart';
import '../../reservation/application/reservation_controller.dart';
import '../application/booking_providers.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';
import 'month_calendar.dart';
import 'price_summary_bar.dart';
import 'slot_picker.dart';

/// Screen 2 · Elegir fecha y horario.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.areaId, this.area});

  final String areaId;

  /// Passed from screen 1; loaded from the area list when missing (deep link).
  final ResidentArea? area;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late DateTime _month;
  late DateTime _today;
  String? _selectedDate;
  SlotOption? _selectedSlot;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _today = buildingToday(ref.read(clockProvider)());
    _month = DateTime(_today.year, _today.month);
  }

  (String, String) get _monthKey => (widget.areaId, toIsoMonth(_month));

  void _changeMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
    _selectedDate = null;
    _selectedSlot = null;
  });

  void _selectDate(String date) => setState(() {
    _selectedDate = date;
    _selectedSlot = null;
  });

  /// First day with free slots, so the screen opens with something useful.
  static String? _firstAvailable(Map<String, bool>? availability) {
    final days = [
      for (final MapEntry(:key, :value)
          in availability?.entries ?? <MapEntry<String, bool>>[])
        if (value) key,
    ]..sort();
    return days.firstOrNull;
  }

  Future<void> _request() async {
    final date =
        _selectedDate ??
        _firstAvailable(ref.read(monthAvailabilityProvider(_monthKey)).value);
    final slot = _selectedSlot;
    if (date == null || slot == null) return;

    setState(() => _submitting = true);
    try {
      final reservation = await ref
          .read(bookingRepositoryProvider)
          .requestReservation(areaId: widget.areaId, date: date, slot: slot);
      // Screen 1 shows «Tu reserva» for it right away.
      ref.invalidate(activeReservationProvider);
      if (!mounted) return;
      context.pushReplacement('/reservations/${reservation.id}');
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
      // Someone may have taken the slot meanwhile: show the current state.
      ref
        ..invalidate(daySlotsProvider((widget.areaId, date)))
        ..invalidate(monthAvailabilityProvider(_monthKey));
      setState(() => _selectedSlot = null);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final area =
        widget.area ?? ref.watch(bookingAreaProvider(widget.areaId)).value;
    final availability = ref.watch(monthAvailabilityProvider(_monthKey));
    final selectedDate = _selectedDate ?? _firstAvailable(availability.value);
    final textTheme = Theme.of(context).textTheme;
    final isCurrentMonth =
        _month.year == _today.year && _month.month == _today.month;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              area?.name ?? '',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Elige fecha y horario',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      body: availability.hasError && !availability.hasValue
          ? ErrorView(
              error: availability.error!,
              onRetry: () =>
                  ref.invalidate(monthAvailabilityProvider(_monthKey)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                MonthCalendar(
                  month: _month,
                  today: _today,
                  availability: availability.value ?? const {},
                  loading: availability.isLoading,
                  selectedDate: selectedDate,
                  onSelect: _selectDate,
                  onPreviousMonth: isCurrentMonth
                      ? null
                      : () => _changeMonth(-1),
                  onNextMonth: () => _changeMonth(1),
                ),
                const SizedBox(height: 24),
                if (selectedDate == null)
                  Text(
                    availability.isLoading
                        ? 'Buscando horarios…'
                        : 'Elige un día con horarios (punto verde).',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  )
                else ...[
                  Text(
                    'Horarios del ${weekdayDayMonth(parseIsoDate(selectedDate))}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ref
                      .watch(daySlotsProvider((widget.areaId, selectedDate)))
                      .when(
                        data: (slots) => SlotPicker(
                          slots: slots,
                          selected: _selectedSlot,
                          onSelect: (slot) =>
                              setState(() => _selectedSlot = slot),
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16),
                          child: LoadingView(),
                        ),
                        error: (error, _) => ErrorView(
                          error: error,
                          onRetry: () => ref.invalidate(
                            daySlotsProvider((widget.areaId, selectedDate)),
                          ),
                        ),
                      ),
                ],
              ],
            ),
      bottomNavigationBar: area == null
          ? null
          : PriceSummaryBar(
              fee: area.fee,
              deposit: area.deposit,
              submitting: _submitting,
              onRequest: _selectedSlot == null ? null : _request,
            ),
    );
  }
}
