import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_input_field_props.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_output.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/date_input/trigger_date_selection_area.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// A tap-to-open date+time field — opens the native date picker, then
/// immediately the native time picker, and combines both into one DateTime.
/// Reports the result via [props.dateChanged].
class DateInputTimeSelection extends StatefulWidget {
  final DateInputFieldProps props;
  const DateInputTimeSelection({super.key, required this.props});

  @override
  State<DateInputTimeSelection> createState() => _DateInputTimeSelectionState();
}

class _DateInputTimeSelectionState extends State<DateInputTimeSelection> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.props.preselectedDate;
  }

  @override
  void didUpdateWidget(covariant DateInputTimeSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.props.preselectedDate != oldWidget.props.preselectedDate) {
      _selectedDate = widget.props.preselectedDate;
    }
  }

  bool get _isInvalid => _selectedDate == null && widget.props.autoValidate;

  Future<void> _showDateThenTimePicker() async {
    final now = DateTime.now();
    final firstDate = widget.props.firstDate ?? DateTime.now().subtract(const Duration(days: 5 * 365));
    final lastDate = widget.props.lastDate ?? DateTime(now.year + 1, now.month, now.day);
    var initialDate = _selectedDate ?? now;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: context.colors.brandPrimary)),
          child: child!,
        );
      },
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: context.colors.brandPrimary)),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

    _changeDate(DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute));
  }

  void _changeDate(DateTime? date) {
    setState(() => _selectedDate = date);
    widget.props.dateChanged(date: DateOutput(date: date, dateString: date?.toIso8601String()));
  }

  void _clearDate() => _changeDate(null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TriggerDateSelectionArea(
          borderColor: _isInvalid ? context.colors.brandError : null,
          title:
              _selectedDate != null
                  ? (widget.props.dateFormat ?? DateFormat('dd/MM/yyyy HH:mm')).format(_selectedDate!)
                  : widget.props.placeholderText ?? '',
          infoTitle: widget.props.infoTitle ?? '',
          itemPressed: _showDateThenTimePicker,
          closePressed: _clearDate,
          isCloseVisible: _selectedDate != null,
        ),
        if (_isInvalid) ...[
          const SizedBox(height: 4),
          Text(
            TranslationStorage.translation.fieldIsRequired,
            style: TextStyle(color: context.colors.brandError, fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ],
    );
  }
}
