import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/http/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/async_states.dart';
import '../../reservation/application/reservation_controller.dart';
import '../../reservation/presentation/active_reservation_banner.dart';
import '../../standing/application/standing_providers.dart';
import '../../standing/data/standing_repository.dart';
import '../../standing/presentation/not_up_to_date_sheet.dart';
import '../application/areas_providers.dart';
import '../data/area_models.dart';
import 'area_card.dart';

/// Screen 1 · Áreas comunes.
class AreasScreen extends ConsumerStatefulWidget {
  const AreasScreen({super.key});

  @override
  ConsumerState<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends ConsumerState<AreasScreen> {
  /// Area whose «Reservar» is checking the resident's standing.
  String? _checkingAreaId;

  Future<void> _refresh() async {
    ref
      ..invalidate(residentProfileProvider)
      ..invalidate(activeReservationProvider)
      ..invalidate(areasProvider);
    await ref.read(areasProvider.future);
  }

  /// Rule 5 before booking: up to date → screen 2, otherwise → screen 4.
  Future<void> _reserve(ResidentArea area) async {
    final Standing standing;
    setState(() => _checkingAreaId = area.id);
    try {
      ref.invalidate(standingProvider);
      standing = await ref.read(standingProvider.future);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    } finally {
      // The spinner only covers the check, not the next screen or the sheet.
      if (mounted) setState(() => _checkingAreaId = null);
    }

    if (!mounted) return;
    if (standing.upToDate) {
      await context.push('/areas/${area.id}/booking', extra: area);
      ref
        ..invalidate(areasProvider)
        ..invalidate(activeReservationProvider);
    } else {
      await showNotUpToDateSheet(context, standing);
    }
  }

  Future<void> _openReservation(String id) async {
    await context.push('/reservations/$id');
    ref.invalidate(activeReservationProvider);
  }

  @override
  Widget build(BuildContext context) {
    final areas = ref.watch(areasProvider);
    final active = ref.watch(activeReservationProvider).value;
    final profile = ref.watch(residentProfileProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Áreas comunes',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              profile.value?.subtitle ?? '',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      body: switch (areas) {
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              if (active case final reservation?) ...[
                ActiveReservationBanner(
                  reservation: reservation,
                  onTap: () => _openReservation(reservation.id),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'Elige un área para ver sus horarios y reservar.',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              for (final area in value) ...[
                const SizedBox(height: 16),
                AreaCard(
                  area: area,
                  busy: _checkingAreaId == area.id,
                  onReserve: () => _reserve(area),
                ),
              ],
            ],
          ),
        ),
        AsyncError(:final error) => ErrorView(error: error, onRetry: _refresh),
        _ => const LoadingView(),
      },
    );
  }
}
