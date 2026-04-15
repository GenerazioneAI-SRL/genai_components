import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'cl_container.widget.dart';

/// Modello per i dati di un giorno nel calendario
class CLCalendarDayData {
  final String dateKey; // formato: yyyy-MM-dd
  final int primaryCount;
  final int secondaryCount;
  final bool hasWarning;
  final Map<String, dynamic>? extra;

  CLCalendarDayData({
    required this.dateKey,
    this.primaryCount = 0,
    this.secondaryCount = 0,
    this.hasWarning = false,
    this.extra,
  });
}

/// Item della legenda
class CLCalendarLegendItem {
  final Color color;
  final String label;

  CLCalendarLegendItem({required this.color, required this.label});
}

/// Widget calendario mensile riutilizzabile
///
/// Esempio d'uso:
/// ```dart
/// CLMonthCalendar(
///   selectedMonth: '2026-02',
///   onMonthChanged: (month) => setState(() => _month = month),
///   dayDataBuilder: (dateKey) => CLCalendarDayData(
///     dateKey: dateKey,
///     primaryCount: 5,
///     secondaryCount: 2,
///     hasWarning: true,
///   ),
///   onDayTap: (date) => print('Tapped: $date'),
///   legendItems: [
///     CLCalendarLegendItem(color: Colors.green, label: 'Presenti'),
///     CLCalendarLegendItem(color: Colors.red, label: 'Assenti'),
///   ],
/// )
/// ```
class CLMonthCalendar extends StatefulWidget {
  const CLMonthCalendar({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.dayDataBuilder,
    this.onDayTap,
    this.selectedDay,
    this.legendItems,
    this.isLoading = false,
    this.primaryColor,
    this.secondaryColor,
    this.warningColor,
    this.showNavigation = true,
    this.showLegend = true,
    this.showTodayButton = true,
    this.dayWeekLabels = const ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'],
    this.todayLabel = 'Oggi',
    this.emptyDayTooltip = 'Nessun dato',
    this.tooltipBuilder,
    this.headerWidget,
  });

  /// Mese selezionato in formato yyyy-MM
  final String selectedMonth;

  /// Callback quando cambia il mese
  final void Function(String newMonth) onMonthChanged;

  /// Builder per ottenere i dati di un giorno specifico
  final CLCalendarDayData? Function(String dateKey) dayDataBuilder;

  /// Callback quando si clicca su un giorno
  final void Function(DateTime date)? onDayTap;

  /// Giorno attualmente selezionato
  final DateTime? selectedDay;

  /// Items della legenda
  final List<CLCalendarLegendItem>? legendItems;

  /// Se sta caricando i dati
  final bool isLoading;

  /// Colore primario per i conteggi positivi (default: theme.success)
  final Color? primaryColor;

  /// Colore secondario per i conteggi negativi (default: theme.danger)
  final Color? secondaryColor;

  /// Colore per i warning (default: theme.warning)
  final Color? warningColor;

  /// Mostra navigazione mesi
  final bool showNavigation;

  /// Mostra legenda
  final bool showLegend;

  /// Mostra pulsante "Oggi"
  final bool showTodayButton;

  /// Labels giorni della settimana
  final List<String> dayWeekLabels;

  /// Label pulsante oggi
  final String todayLabel;

  /// Tooltip per giorni vuoti
  final String emptyDayTooltip;

  /// Builder custom per tooltip (se null usa default)
  final String Function(CLCalendarDayData? data, String dateKey)? tooltipBuilder;

  /// Widget custom da mostrare nell'header a sinistra della navigazione
  final Widget? headerWidget;

  @override
  State<CLMonthCalendar> createState() => _CLMonthCalendarState();
}

class _CLMonthCalendarState extends State<CLMonthCalendar> {
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth;
  }

  @override
  void didUpdateWidget(CLMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _currentMonth = widget.selectedMonth;
    }
  }

  void _previousMonth() {
    final date = DateTime.parse('$_currentMonth-01');
    final newDate = DateTime(date.year, date.month - 1, 1);
    final newMonth = DateFormat('yyyy-MM').format(newDate);
    setState(() => _currentMonth = newMonth);
    widget.onMonthChanged(newMonth);
  }

  void _nextMonth() {
    final date = DateTime.parse('$_currentMonth-01');
    final newDate = DateTime(date.year, date.month + 1, 1);
    final newMonth = DateFormat('yyyy-MM').format(newDate);
    setState(() => _currentMonth = newMonth);
    widget.onMonthChanged(newMonth);
  }

  void _goToToday() {
    final newMonth = DateFormat('yyyy-MM').format(DateTime.now());
    setState(() => _currentMonth = newMonth);
    widget.onMonthChanged(newMonth);
    widget.onDayTap?.call(DateTime.now());
  }

  String get _monthDisplayName {
    final date = DateTime.parse('$_currentMonth-01');
    final monthName = DateFormat('MMMM', 'it_IT').format(date);
    return '${monthName[0].toUpperCase()}${monthName.substring(1)} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final primaryColor = widget.primaryColor ?? theme.success;
    final secondaryColor = widget.secondaryColor ?? theme.danger;
    final warningColor = widget.warningColor ?? theme.warning;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.maxHeight.isFinite;

        final content = [
          if (widget.showNavigation) ...[
            _buildMonthNavigation(theme),
            SizedBox(height: Sizes.padding),
          ],
          if (hasBoundedHeight)
            Expanded(child: _buildCalendarGrid(theme, primaryColor, secondaryColor, warningColor, hasBoundedHeight: true))
          else
            _buildCalendarGrid(theme, primaryColor, secondaryColor, warningColor, hasBoundedHeight: false),
        ];

        return Column(
          mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
          children: content,
        );
      },
    );
  }

  Widget _buildMonthNavigation(CLTheme theme) {
    return CLContainer(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.75),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 500;

          if (isCompact) {
            // Layout compatto per mobile: senza headerWidget e bottone oggi
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavButton(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  onTap: _previousMonth,
                  tooltip: 'Mese precedente',
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Sizes.borderRadius),
                    ),
                    child: Text(
                      _monthDisplayName,
                      style: theme.bodyLabel.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _NavButton(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  onTap: _nextMonth,
                  tooltip: 'Mese successivo',
                ),
              ],
            );
          }

          // Layout standard per desktop
          return Row(
            children: [
              if (widget.headerWidget != null) ...[
                Flexible(child: widget.headerWidget!),
                const SizedBox(width: Sizes.padding),
              ],
              const Spacer(),
              _NavButton(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                onTap: _previousMonth,
                tooltip: 'Mese precedente',
              ),
              const SizedBox(width: Sizes.padding),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
                child: Text(
                  _monthDisplayName,
                  style: theme.bodyLabel.copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: Sizes.padding),
              _NavButton(
                icon: HugeIcons.strokeRoundedArrowRight01,
                onTap: _nextMonth,
                tooltip: 'Mese successivo',
              ),
              if (widget.showTodayButton) ...[
                const SizedBox(width: Sizes.padding * 1.5),
                _TodayButton(
                  label: widget.todayLabel,
                  onTap: _goToToday,
                ),
              ],
              const Spacer(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(CLTheme theme, Color primaryColor, Color secondaryColor, Color warningColor, {bool hasBoundedHeight = false}) {
    final monthDate = DateTime.parse('$_currentMonth-01');
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstDayWeekday = monthDate.weekday;
    final today = DateTime.now();
    final todayKey = DateFormat('yyyy-MM-dd').format(today);

    Widget gridContent;
    if (widget.isLoading) {
      gridContent = const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      gridContent = GridView.builder(
        shrinkWrap: !hasBoundedHeight,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayOffset = index - (firstDayWeekday - 1);
                if (dayOffset < 0 || dayOffset >= daysInMonth) {
                  return const SizedBox();
                }

                final day = dayOffset + 1;
                final dateKey = '$_currentMonth-${day.toString().padLeft(2, '0')}';
                final date = DateTime.parse(dateKey);
                final isWeekend = date.weekday == 6 || date.weekday == 7;
                final isToday = dateKey == todayKey;
                final isSelected = widget.selectedDay != null &&
                    DateFormat('yyyy-MM-dd').format(widget.selectedDay!) == dateKey;

                final dayData = widget.dayDataBuilder(dateKey);

                return _DayCell(
                  day: day,
                  dateKey: dateKey,
                  isWeekend: isWeekend,
                  isToday: isToday,
                  isSelected: isSelected,
                  dayData: dayData,
                  primaryColor: primaryColor,
                  secondaryColor: secondaryColor,
                  warningColor: warningColor,
                  emptyTooltip: widget.emptyDayTooltip,
                  tooltipBuilder: widget.tooltipBuilder,
                  onTap: () => widget.onDayTap?.call(date),
                );
              },
            );
    }

    return CLContainer(
      contentPadding: const EdgeInsets.all(Sizes.padding),
      child: Column(
        mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _buildWeekHeader(theme),
          Divider(color: theme.borderColor, height: Sizes.padding),
          if (hasBoundedHeight)
            Expanded(child: gridContent)
          else
            gridContent,
          if (widget.showLegend && widget.legendItems != null && widget.legendItems!.isNotEmpty) ...[
            SizedBox(height: Sizes.padding),
            _buildLegend(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekHeader(CLTheme theme) {
    return Row(
      children: widget.dayWeekLabels.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isWeekend = index >= 5;
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                day,
                style: theme.smallLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isWeekend ? theme.danger : theme.secondaryText,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend(CLTheme theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: widget.legendItems!.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item.label,
              style: theme.smallLabel.copyWith(
                fontSize: 10,
                color: theme.secondaryText,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ── Widget privati ──────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final dynamic icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.borderColor),
          ),
          child: HugeIcon(icon: icon, color: theme.primary, size: 18),
        ),
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    return Tooltip(
      message: 'Vai ad oggi',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, color: theme.primary, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.smallLabel.copyWith(
                  color: theme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dateKey,
    required this.isWeekend,
    required this.isToday,
    required this.isSelected,
    required this.dayData,
    required this.primaryColor,
    required this.secondaryColor,
    required this.warningColor,
    required this.emptyTooltip,
    required this.onTap,
    this.tooltipBuilder,
  });

  final int day;
  final String dateKey;
  final bool isWeekend;
  final bool isToday;
  final bool isSelected;
  final CLCalendarDayData? dayData;
  final Color primaryColor;
  final Color secondaryColor;
  final Color warningColor;
  final String emptyTooltip;
  final VoidCallback onTap;
  final String Function(CLCalendarDayData? data, String dateKey)? tooltipBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final hasData = dayData != null && (dayData!.primaryCount > 0 || dayData!.secondaryCount > 0);
    final hasWarning = dayData?.hasWarning ?? false;

    Color bgColor = Colors.transparent;
    Color borderColor = Colors.transparent;

    if (isSelected) {
      bgColor = theme.primary.withValues(alpha: 0.15);
      borderColor = theme.primary;
    } else if (isToday) {
      bgColor = theme.primary.withValues(alpha: 0.08);
      borderColor = theme.primary.withValues(alpha: 0.5);
    } else if (hasWarning) {
      bgColor = warningColor.withValues(alpha: 0.08);
    }

    String tooltip;
    if (tooltipBuilder != null) {
      tooltip = tooltipBuilder!(dayData, dateKey);
    } else if (hasData) {
      final parts = <String>[];
      if (dayData!.primaryCount > 0) parts.add('${dayData!.primaryCount}');
      if (dayData!.secondaryCount > 0) parts.add('${dayData!.secondaryCount}');
      if (hasWarning) parts.add('Con avvisi');
      tooltip = parts.join(' - ');
    } else {
      tooltip = emptyTooltip;
    }

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.borderRadius * 0.75),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(Sizes.borderRadius * 0.75),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calcola se c'è abbastanza spazio per i badge
              final cellHeight = constraints.maxHeight;
              final showBadges = cellHeight > 40;
              final showWarning = cellHeight > 50;
              final fontSize = cellHeight > 50 ? 14.0 : (cellHeight > 35 ? 12.0 : 10.0);

              return ClipRect(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isWeekend
                                ? theme.danger
                                : (isSelected ? theme.primary : theme.primaryText),
                          ),
                        ),
                        if (showBadges && hasData) ...[
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (dayData!.primaryCount > 0)
                                _CountBadge(
                                  count: dayData!.primaryCount,
                                  color: primaryColor,
                                  compact: cellHeight < 60,
                                ),
                              if (dayData!.primaryCount > 0 && dayData!.secondaryCount > 0)
                                const SizedBox(width: 2),
                              if (dayData!.secondaryCount > 0)
                                _CountBadge(
                                  count: dayData!.secondaryCount,
                                  color: secondaryColor,
                                  compact: cellHeight < 60,
                                ),
                            ],
                          ),
                          if (hasWarning && showWarning) ...[
                            const SizedBox(height: 2),
                            Container(
                              width: 10,
                              height: 2,
                              decoration: BoxDecoration(
                                color: warningColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ] else if (hasData) ...[
                          // Su spazi molto piccoli, mostra solo un dot colorato
                          const SizedBox(height: 1),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: dayData!.primaryCount > 0 ? primaryColor : secondaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ] else if (showBadges) ...[
                          const SizedBox(height: 1),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: theme.secondaryText.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.color,
    this.compact = false,
  });

  final int count;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 3 : 5,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

