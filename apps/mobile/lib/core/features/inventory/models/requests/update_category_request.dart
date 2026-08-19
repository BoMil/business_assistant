/// JSON body for PUT /categories/{id} — mirrors the Business API's UpdateCategoryRequest.
class UpdateCategoryRequest {
  final String name;
  final String? imgUrl;

  const UpdateCategoryRequest({required this.name, this.imgUrl});

  Map<String, dynamic> toJson() => {'name': name, 'imgUrl': imgUrl};
}
