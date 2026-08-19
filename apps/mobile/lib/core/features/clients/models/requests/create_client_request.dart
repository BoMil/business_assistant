/// JSON body for POST /clients — mirrors the Business API's CreateClientRequest.
class CreateClientRequest {
  final String name;
  final String phoneNumber;
  final String email;
  final String? locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? description;

  const CreateClientRequest({
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
