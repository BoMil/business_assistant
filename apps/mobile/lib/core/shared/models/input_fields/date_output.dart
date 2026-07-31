/// The value emitted by DateInputField when the user picks or clears a date.
class DateOutput {
  final DateTime? date;
  final String? dateString;

  DateOutput({required this.date, required this.dateString});
}
