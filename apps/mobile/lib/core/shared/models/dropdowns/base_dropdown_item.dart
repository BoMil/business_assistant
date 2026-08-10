import 'package:flutter/widgets.dart';

/// A single selectable row for SelectionBottomModal — [value] carries the
/// underlying id (e.g. an Asset or Client Guid), [text]/[subtitle] are what's shown.
/// [rightContent] is shown on the trailing edge of the row (e.g. a price).
class BaseDropdownItem {
  final String text;
  final String? subtitle;
  final Widget? rightContent;
  final dynamic value;

  const BaseDropdownItem({required this.text, required this.value, this.subtitle, this.rightContent});
}
