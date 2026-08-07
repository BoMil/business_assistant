/// One product line on an event — mirrors the Business API's
/// TransactionLineItemRequest (AssetId, Quantity, Price).
class EventAssetRequest {
  final String assetId;
  final int quantity;
  final double price;

  const EventAssetRequest({required this.assetId, required this.quantity, required this.price});

  Map<String, dynamic> toJson() => {
        'assetId': assetId,
        'quantity': quantity,
        'price': price,
      };
}
