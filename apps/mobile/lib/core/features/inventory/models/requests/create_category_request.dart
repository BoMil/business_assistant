/// JSON body for POST /categories — mirrors the Business API's CreateCategoryRequest.
class CreateCategoryRequest {
  final String name;
  final String? imgUrl;

  const CreateCategoryRequest({required this.name, this.imgUrl});

  Map<String, dynamic> toJson() => {'name': name, 'imgUrl': imgUrl};
}
