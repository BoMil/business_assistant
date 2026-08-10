import 'package:flutter/material.dart';
import 'package:business_assistant/core/shared/models/input_fields/date_input_field_props.dart';
import 'package:business_assistant/core/shared/widgets/buttons/switch_button.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/date_input/date_input_time_selection.dart';

/// A CardFrame with a From/To date range and an "All day" switch. When All
/// day is on, picking a date on either field skips the time picker and
/// applies that same date to both From and To — mirrors Google Calendar's
/// all-day event behavior.
class DateSelectionCard extends StatefulWidget {
  final String title;
  final String allDayLabel;
  final String fromLabel;
  final String toLabel;
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime?> onFromChanged;
  final ValueChanged<DateTime?> onToChanged;

  const DateSelectionCard({
    super.key,
    required this.title,
    required this.allDayLabel,
    required this.fromLabel,
    required this.toLabel,
    required this.from,
    required this.to,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  State<DateSelectionCard> createState() => _DateSelectionCardState();
}

class _DateSelectionCardState extends State<DateSelectionCard> {
  bool _isAllDay = false;
  DateTime? _lastPickedDate;

  @override
  void initState() {
    super.initState();
    _lastPickedDate = widget.from ?? widget.to;
  }

  void _handleFromChanged(DateTime? date) {
    _lastPickedDate = date;
    widget.onFromChanged(date);
    if (_isAllDay) widget.onToChanged(date);
  }

  void _handleToChanged(DateTime? date) {
    _lastPickedDate = date;
    widget.onToChanged(date);
    if (_isAllDay) widget.onFromChanged(date);
  }

  void _handleAllDayChanged(bool value) {
    setState(() => _isAllDay = value);
    if (value && _lastPickedDate != null) {
      widget.onFromChanged(_lastPickedDate);
      widget.onToChanged(_lastPickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      headerSectionTtitle: widget.title,
      headerSectionRightContent: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.allDayLabel),
          const SizedBox(width: 8),
          SwitchButton(isActive: _isAllDay, onChanged: _handleAllDayChanged),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DateInputTimeSelection(
            props: DateInputFieldProps(
              infoTitle: widget.fromLabel,
              placeholderText: widget.fromLabel,
              preselectedDate: widget.from,
              includeTime: !_isAllDay,
              dateChanged: ({required date}) => _handleFromChanged(date.date),
            ),
          ),
          const SizedBox(height: 12),
          DateInputTimeSelection(
            props: DateInputFieldProps(
              infoTitle: widget.toLabel,
              placeholderText: widget.toLabel,
              preselectedDate: widget.to,
              firstDate: widget.from,
              includeTime: !_isAllDay,
              dateChanged: ({required date}) => _handleToChanged(date.date),
            ),
          ),

          // Test/reference alternate implementation, using DateInputField's
          // combined native date+time picker instead of DateInputTimeSelection's
          // sequential date-then-time pickers. Kept for comparison, not used.
          // DateInputField(
          //   props: DateInputFieldProps(
          //     infoTitle: widget.fromLabel,
          //     placeholderText: widget.fromLabel,
          //     preselectedDate: widget.from,
          //     includeTime: true,
          //     dateChanged: ({required date}) => _handleFromChanged(date.date),
          //   ),
          // ),
          // const SizedBox(height: 12),
          // DateInputField(
          //   props: DateInputFieldProps(
          //     infoTitle: widget.toLabel,
          //     placeholderText: widget.toLabel,
          //     preselectedDate: widget.to,
          //     firstDate: widget.from,
          //     includeTime: true,
          //     dateChanged: ({required date}) => _handleToChanged(date.date),
          //   ),
          // ),
        ],
      ),
    );
  }
}
