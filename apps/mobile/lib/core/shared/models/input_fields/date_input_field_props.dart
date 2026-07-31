import 'package:intl/intl.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_output.dart';

class DateInputFieldProps {
  final String? placeholderText;
  final String? infoTitle;
  final Function({required DateOutput date}) dateChanged;
  final bool autoValidate;
  final DateTime? preselectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? dateFormat;
  final bool includeTime;

  const DateInputFieldProps({
    required this.dateChanged,
    this.autoValidate = false,
    this.placeholderText,
    this.infoTitle,
    this.preselectedDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.includeTime = false,
  });
}
