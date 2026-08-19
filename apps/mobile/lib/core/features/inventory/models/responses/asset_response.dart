/// Response body for a single item in GET /assets — mirrors the Business API's
/// AssetDto. Used by the Events feature's "Add product" picker.
class AssetResponse {
  final String id;
  final String name;
  final String? categoryId;
  final String? categoryName;
  final String? description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;
  final String? imgUrl;

  AssetResponse({
    required this.id,
    required this.name,
    required this.stockCount,
    this.categoryId,
    this.categoryName,
    this.description,
    this.salePrice,
    this.rentalPrice,
    this.imgUrl,
  });

  factory AssetResponse.fromJson(Map<String, dynamic> json) {
    return AssetResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      description: json['description'] as String?,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble(),
      stockCount: json['stockCount'] as int? ?? 0,
      imgUrl: json['imgUrl'] as String?,
    );
  }
}
