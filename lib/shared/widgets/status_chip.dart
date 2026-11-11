import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum ChipTone { success, info, warning, danger, neutral }

/// Pill with a colored dot: «Disponible hoy», «Esperando aprobación», «Confirmada»…
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground, dot) = switch (tone) {
      ChipTone.success => (
        AppColors.successSoft,
        AppColors.successBorder,
        AppColors.successText,
        AppColors.success,
      ),
      ChipTone.info => (
        AppColors.primarySoft,
        AppColors.primaryBorder,
        AppColors.primaryText,
        AppColors.primary,
      ),
      ChipTone.warning => (
        AppColors.warningSoft,
        AppColors.warningBorder,
        AppColors.warningText,
        AppColors.warning,
      ),
      ChipTone.danger => (
        AppColors.dangerSoft,
        AppColors.dangerBorder,
        AppColors.danger,
        AppColors.danger,
      ),
      ChipTone.neutral => (
        AppColors.neutralSoft,
        AppColors.border,
        AppColors.textMuted,
        AppColors.textMuted,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
