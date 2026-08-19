/// JSON body for POST /assets — mirrors the Business API's CreateAssetRequest.
class CreateAssetRequest {
  final String name;
  final String? categoryId;
  final String? description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;
  final String? imgUrl;

  const CreateAssetRequest({
    required this.name,
    required this.stockCount,
    this.categoryId,
    this.description,
    this.salePrice,
    this.rentalPrice,
    this.imgUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'categoryId': categoryId,
        'description': description,
        'salePrice': salePrice,
        'rentalPrice': rentalPrice,
        'stockCount': stockCount,
        'imgUrl': imgUrl,
      };
}
