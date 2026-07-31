/// Response body for a single item in GET /assets — mirrors the Business API's
/// AssetDto. Used by the Events feature's "Add product" picker.
class AssetResponse {
  final String id;
  final String name;
  final String category;
  final String? description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;

  AssetResponse({
    required this.id,
    required this.name,
    required this.category,
    required this.stockCount,
    this.description,
    this.salePrice,
    this.rentalPrice,
  });

  factory AssetResponse.fromJson(Map<String, dynamic> json) {
    return AssetResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble(),
      stockCount: json['stockCount'] as int? ?? 0,
    );
  }
}
