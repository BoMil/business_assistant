/// Response body for a single item in GET /clients — mirrors the Business API's
/// ClientDto. Used by the Events feature's optional "Select client" picker.
class ClientResponse {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String? locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? description;

  ClientResponse({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.locationAddress,
    this.locationLatitude,
    this.locationLongitude,
    this.description,
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) {
    return ClientResponse(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      locationAddress: json['locationAddress'] as String?,
      locationLatitude: (json['locationLatitude'] as num?)?.toDouble(),
      locationLongitude: (json['locationLongitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }
}
