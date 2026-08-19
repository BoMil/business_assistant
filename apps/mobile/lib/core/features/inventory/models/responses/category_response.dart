/// Response body for a single item in GET /categories — mirrors the Business
/// API's CategoryDto. Used by the Inventory feature's category picker.
class CategoryResponse {
  final String id;
  final String name;
  final String? imgUrl;

  CategoryResponse({required this.id, required this.name, this.imgUrl});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      imgUrl: json['imgUrl'] as String?,
    );
  }
}
