/// A single selectable row for SelectionBottomModal — [value] carries the
/// underlying id (e.g. an Asset or Client Guid), [text]/[subtitle] are what's shown.
class BaseDropdownItem {
  final String text;
  final String? subtitle;
  final dynamic value;

  const BaseDropdownItem({required this.text, required this.value, this.subtitle});
}
