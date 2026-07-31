/// Mirrors the Business API's TransactionLineItemDto — includes the asset's
/// name (resolved server-side) so the UI doesn't need a second lookup.
class EventLineItemResponse {
  final String assetId;
  final String assetName;
  final int quantity;
  final double price;

  EventLineItemResponse({
    required this.assetId,
    required this.assetName,
    required this.quantity,
    required this.price,
  });

  factory EventLineItemResponse.fromJson(Map<String, dynamic> json) {
    return EventLineItemResponse(
      assetId: json['assetId'] as String,
      assetName: json['assetName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
