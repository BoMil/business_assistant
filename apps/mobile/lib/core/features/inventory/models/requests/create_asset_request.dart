/// JSON body for POST /assets — mirrors the Business API's CreateAssetRequest.
class CreateAssetRequest {
  final String name;
  final String category;
  final String? description;
  final double? salePrice;
  final double? rentalPrice;
  final int stockCount;
  final String? imgUrl;

  const CreateAssetRequest({
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
