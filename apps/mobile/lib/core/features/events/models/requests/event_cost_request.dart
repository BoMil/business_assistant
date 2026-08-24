/// One additional cost line on an event — mirrors the Business API's
/// TransactionCostRequest (Title, Cost, IsIncludedInTotalCost).
class EventCostRequest {
  final String title;
  final double cost;
  final bool isIncludedInTotalCost;

  const EventCostRequest({required this.title, required this.cost, required this.isIncludedInTotalCost});

  Map<String, dynamic> toJson() => {
        'title': title,
        'cost': cost,
        'isIncludedInTotalCost': isIncludedInTotalCost,
      };
}
