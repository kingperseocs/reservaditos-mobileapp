import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/formatters/formatters.dart';

const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _pastColor = Color(0xFFCBD5E1);

/// Month calendar of screen 2. Presentational: availability in, taps out.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.availability,
    required this.selectedDate,
    required this.onSelect,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.loading = false,
  });

  /// First day of the month shown.
  final DateTime month;
  final DateTime today;

  /// yyyy-MM-dd → has free slots. Missing days count as unavailable.
  final Map<String, bool> availability;
  final String? selectedDate;
  final ValueChanged<String> onSelect;

  /// Null hides the arrow's action (e.g. before the current month).
  final VoidCallback? onPreviousMonth;
  final VoidCallback onNextMonth;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final leadingBlanks = month.weekday - 1; // Monday first

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            Row(
              children: [
                _ArrowButton(
                  icon: Icons.chevron_left,
                  label: 'Mes anterior',
                  onPressed: onPreviousMonth,
                ),
                Expanded(
                  child: Text(
                    monthTitle(month),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                _ArrowButton(
                  icon: Icons.chevron_right,
                  label: 'Mes siguiente',
                  onPressed: onNextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final day in _weekdays)
                  Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: loading ? 0.4 : 1,
              duration: const Duration(milliseconds: 150),
              child: GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                children: [
                  for (var i = 0; i < leadingBlanks; i++)
                    const SizedBox.shrink(),
                  for (var day = 1; day <= daysInMonth; day++)
                    _DayCell(
                      date: DateTime(month.year, month.month, day),
                      today: today,
                      available:
                          availability[toIsoDate(
                            DateTime(month.year, month.month, day),
                          )] ??
                          false,
                      selected:
                          selectedDate ==
                          toIsoDate(DateTime(month.year, month.month, day)),
                      onTap: onSelect,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _Legend(),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.available,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final bool available;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isPast = date.isBefore(DateUtils.dateOnly(today));
    final isToday = DateUtils.isSameDay(date, today);
    final enabled = available && !isPast;

    final Color textColor;
    if (selected) {
      textColor = Colors.white;
    } else if (isPast) {
      textColor = _pastColor;
    } else if (isToday) {
      textColor = AppColors.primary;
    } else if (available) {
      textColor = AppColors.text;
    } else {
      textColor = AppColors.textSubtle;
    }

    final dotColor = selected ? Colors.white : AppColors.success;

    return Semantics(
      button: enabled,
      selected: selected,
      label: '${date.day}${enabled ? ', con horarios' : ''}',
      excludeSemantics: true,
      child: InkResponse(
        onTap: enabled ? () => onTap(toIsoDate(date)) : null,
        radius: 24,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : null,
              border: isToday && !selected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: selected || isToday
                        ? FontWeight.w600
                        : FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled ? dotColor : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        side: const BorderSide(color: AppColors.border),
        foregroundColor: AppColors.text,
        disabledForegroundColor: _pastColor,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: AppColors.textMuted);
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );

    // Wrap, not Row: on narrow phones the legend goes to a second line.
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        item(AppColors.success, 'Con horarios'),
        item(_pastColor, 'Sin horarios'),
        item(AppColors.primary, 'Elegido'),
      ],
    );
  }
}
