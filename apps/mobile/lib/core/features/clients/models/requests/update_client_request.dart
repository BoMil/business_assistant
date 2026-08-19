/// JSON body for PUT /clients/{id} — mirrors the Business API's UpdateClientRequest.
class UpdateClientRequest {
  final String name;
  final String phoneNumber;
  final String email;
  final String? locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? description;

  const UpdateClientRequest({
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.locationAddress,
    this.locationLatitude,
    this.locationLongitude,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'locationAddress': locationAddress,
        'locationLatitude': locationLatitude,
        'locationLongitude': locationLongitude,
        'description': description,
      };
}
