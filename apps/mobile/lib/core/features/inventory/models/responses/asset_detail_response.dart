/// Response body for GET /assets/{id} — mirrors the Business API's
/// AssetDetailDto. Same fields as AssetResponse plus currentlyReserved
/// (view-only, derived server-side, only shown on the detail view).
class AssetDetailResponse {
  final String id;
  final String name;
  final String? categoryId;
  final String? categoryName;
  final String? description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;
  final int currentlyReserved;
  final String? imgUrl;

  AssetDetailResponse({
    required this.id,
    required this.name,
    required this.stockCount,
    required this.currentlyReserved,
    this.categoryId,
    this.categoryName,
    this.description,
    this.salePrice,
    this.rentalPrice,
    this.imgUrl,
  });

  factory AssetDetailResponse.fromJson(Map<String, dynamic> json) {
    return AssetDetailResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      description: json['description'] as String?,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble(),
      stockCount: json['stockCount'] as int? ?? 0,
      currentlyReserved: json['currentlyReserved'] as int? ?? 0,
      imgUrl: json['imgUrl'] as String?,
    );
  }
}
