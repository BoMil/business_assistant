/// Mirrors the Business API's TransactionCostDto.
class EventCostResponse {
  final String id;
  final String title;
  final double cost;
  final bool isIncludedInTotalCost;

  EventCostResponse({
    required this.id,
    required this.title,
    required this.cost,
    required this.isIncludedInTotalCost,
  });

  factory EventCostResponse.fromJson(Map<String, dynamic> json) {
    return EventCostResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      isIncludedInTotalCost: json['isIncludedInTotalCost'] as bool? ?? false,
    );
  }
}
