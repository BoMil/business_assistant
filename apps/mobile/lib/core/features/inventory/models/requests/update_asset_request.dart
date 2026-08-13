/// JSON body for PUT /assets/{id} — mirrors the Business API's UpdateAssetRequest.
class UpdateAssetRequest {
  final String name;
  final String category;
  final String? description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;
  final String? imgUrl;

  const UpdateAssetRequest({
    required this.name,
    required this.category,
    required this.stockCount,
    this.description,
    this.salePrice,
    this.rentalPrice,
    this.imgUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'description': description,
        'salePrice': salePrice,
        'rentalPrice': rentalPrice,
        'stockCount': stockCount,
        'imgUrl': imgUrl,
      };
}
