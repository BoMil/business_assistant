/// JSON body for PUT /identity/users/me/image.
class UpdateUserImageRequest {
  final String? imgUrl;

  const UpdateUserImageRequest({this.imgUrl});

  Map<String, dynamic> toJson() => {'imgUrl': imgUrl};
}
