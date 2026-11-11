import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Backend icon keys → Material icons, as drawn in the Figma.
IconData areaIconData(String key) => switch (key) {
  'flame' => Icons.local_fire_department_outlined,
  'users' => Icons.group_outlined,
  'waves' => Icons.waves,
  _ => Icons.meeting_room_outlined,
};

/// Light blue square with the area icon.
class AreaIcon extends StatelessWidget {
  const AreaIcon({super.key, required this.icon, this.size = 72});

  final String icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(size * 0.14),
      ),
      child: Icon(
        areaIconData(icon),
        color: AppColors.primary,
        size: size * 0.42,
      ),
    );
  }
}
