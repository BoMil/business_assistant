import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as datetime_picker;
import 'package:intl/intl.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_input_field_props.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_output.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/date_input/trigger_date_selection_area.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// A tap-to-open date field — shows a native date picker themed with the
/// tenant's brand color, and reports the chosen date via [props.dateChanged].
class DateInputField extends StatefulWidget {
  final DateInputFieldProps props;
  const DateInputField({super.key, required this.props});

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends State<DateInputField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.props.preselectedDate;
  }

  @override
  void didUpdateWidget(covariant DateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.props.preselectedDate != oldWidget.props.preselectedDate) {
      _selectedDate = widget.props.preselectedDate;
    }
  }

  bool get _isInvalid => _selectedDate == null && widget.props.autoValidate;

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final firstDate = widget.props.firstDate ?? DateTime.now().subtract(const Duration(days: 5 * 365));
    final lastDate = widget.props.lastDate ?? DateTime(now.year + 1, now.month, now.day);
    var initialDate = _selectedDate ?? now;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    if (widget.props.includeTime) {
      datetime_picker.DatePicker.showDateTimePicker(
        context,
        currentTime: initialDate,
        minTime: firstDate,
        maxTime: lastDate,
        theme: datetime_picker.DatePickerTheme(
          backgroundColor: context.colors.baseWhite,
          headerColor: context.colors.baseWhite,
          itemStyle: TextStyle(color: context.colors.primaryText, fontSize: 16, fontWeight: FontWeight.w500),
          doneStyle: TextStyle(color: context.colors.brandPrimary, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onConfirm: _changeDate,
      );
      return;
    }

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

    if (pickedDate != null) _changeDate(pickedDate);
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
                  ? (widget.props.dateFormat ??
                          DateFormat(widget.props.includeTime ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy'))
                      .format(_selectedDate!)
                  : widget.props.placeholderText ?? '',
          infoTitle: widget.props.infoTitle ?? '',
          itemPressed: _showDatePicker,
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
