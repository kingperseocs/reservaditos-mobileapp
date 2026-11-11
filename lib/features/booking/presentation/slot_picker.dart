import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/booking_models.dart';

/// Row of slots for the selected day: Libre / Ocupado / Elegido.
class SlotPicker extends StatelessWidget {
  const SlotPicker({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelect,
  });

  final List<SlotOption> slots;
  final SlotOption? selected;
  final ValueChanged<SlotOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, slot) in slots.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _SlotTile(
              slot: slot,
              selected: selected?.start == slot.start,
              onTap: () => onSelect(slot),
            ),
          ),
        ],
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final SlotOption slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final free = slot.status == SlotStatus.free;
    final (
      background,
      border,
      borderWidth,
      timeColor,
      status,
      statusColor,
    ) = switch ((selected, slot.status)) {
      (true, _) => (
        AppColors.primarySoft,
        AppColors.primary,
        2.0,
        AppColors.primary,
        'Elegido',
        AppColors.primary,
      ),
      (_, SlotStatus.free) => (
        AppColors.surface,
        AppColors.border,
        1.0,
        AppColors.text,
        'Libre',
        AppColors.successText,
      ),
      (_, SlotStatus.taken) => (
        AppColors.neutralSoft,
        AppColors.border,
        1.0,
        AppColors.textSubtle,
        'Ocupado',
        AppColors.textSubtle,
      ),
      (_, SlotStatus.unavailable) => (
        AppColors.neutralSoft,
        AppColors.border,
        1.0,
        AppColors.textSubtle,
        'No disponible',
        AppColors.textSubtle,
      ),
    };

    return Semantics(
      button: free,
      selected: selected,
      label: '${slot.label}, $status',
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: border, width: borderWidth),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: free ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              children: [
                FittedBox(
                  child: Text(
                    slot.label,
                    style: TextStyle(
                      color: timeColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
