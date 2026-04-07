import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Future<String?> showDatePickerDialog({
  required BuildContext context,
  DateTime? initialDate,
  int pastYearRange = 10,
  int futureYearRange = 10,
  bool useRootNavigator = false,
  bool barrierDismissible = false,
  String title = '選擇日期',
  String cancelText = '取消',
  String confirmText = '確認',
}) {
  final now = DateTime.now();
  final safeInitialDate = initialDate ?? now;

  return showDialog<String>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return _DatePickerDialog(
        initialDate: safeInitialDate,
        pastYearRange: pastYearRange,
        futureYearRange: futureYearRange,
        title: title,
        cancelText: cancelText,
        confirmText: confirmText,
      );
    },
  );
}

class _DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final int pastYearRange;
  final int futureYearRange;
  final String title;
  final String cancelText;
  final String confirmText;

  const _DatePickerDialog({
    required this.initialDate,
    required this.pastYearRange,
    required this.futureYearRange,
    required this.title,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  static const double _itemExtent = 44;

  late final List<int> _years;
  late List<int> _days;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List<int>.generate(
      widget.pastYearRange + widget.futureYearRange + 1,
      (index) => currentYear - widget.pastYearRange + index,
    );

    _selectedYear = _clampYear(widget.initialDate.year);
    _selectedMonth = widget.initialDate.month;
    _days = _buildDays(_selectedYear, _selectedMonth);
    _selectedDay = _clampDay(widget.initialDate.day, _days.length);

    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDay - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _formatDate(_selectedYear, _selectedMonth, _selectedDay),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: _PickerColumn(
                      label: '年',
                      controller: _yearController,
                      itemCount: _years.length,
                      itemBuilder: (index) => '${_years[index]}',
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedYear = _years[index];
                          _syncDays();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _PickerColumn(
                      label: '月',
                      controller: _monthController,
                      itemCount: 12,
                      itemBuilder: (index) => _twoDigits(index + 1),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMonth = index + 1;
                          _syncDays();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _PickerColumn(
                      label: '日',
                      controller: _dayController,
                      itemCount: _days.length,
                      itemBuilder: (index) => _twoDigits(_days[index]),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedDay = _days[index];
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              _formatDate(_selectedYear, _selectedMonth, _selectedDay),
            );
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }

  int _clampYear(int year) {
    if (_years.contains(year)) {
      return year;
    }
    if (year < _years.first) {
      return _years.first;
    }
    return _years.last;
  }

  int _clampDay(int day, int maxDay) {
    if (day < 1) {
      return 1;
    }
    if (day > maxDay) {
      return maxDay;
    }
    return day;
  }

  void _syncDays() {
    _days = _buildDays(_selectedYear, _selectedMonth);
    _selectedDay = _clampDay(_selectedDay, _days.length);
    _dayController.dispose();
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDay - 1,
    );
  }

  List<int> _buildDays(int year, int month) {
    final dayCount = DateUtils.getDaysInMonth(year, month);
    return List<int>.generate(dayCount, (index) => index + 1);
  }

  String _formatDate(int year, int month, int day) {
    return '$year-${_twoDigits(month)}-${_twoDigits(day)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _PickerColumn extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  const _PickerColumn({
    required this.label,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Container(
                    height: _DatePickerDialogState._itemExtent,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                ),
              ),
              ScrollConfiguration(
                behavior: const _DatePickerScrollBehavior(),
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: _DatePickerDialogState._itemExtent,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.003,
                  diameterRatio: 1.6,
                  onSelectedItemChanged: onSelectedItemChanged,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: itemCount,
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          itemBuilder(index),
                          style: theme.textTheme.titleMedium,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DatePickerScrollBehavior extends MaterialScrollBehavior {
  const _DatePickerScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}
