import 'package:business_assistant/core/features/events/models/requests/event_asset_request.dart';

/// JSON body for PUT /transactions/{id} — mirrors the Business API's
/// UpdateTransactionRequest (no `type`, it can't change after creation).
class UpdateEventRequest {
  final String title;
  final String? description;
  final DateTime from;
  final DateTime to;
  final String locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? clientId;
  final List<EventAssetRequest> eventAssets;

  const UpdateEventRequest({
    required this.title,
    required this.from,
    required this.to,
    required this.locationAddress,
    this.description,
    this.locationLatitude,
    this.locationLongitude,
    this.clientId,
    this.eventAssets = const [],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'locationAddress': locationAddress,
        'locationLatitude': locationLatitude,
        'locationLongitude': locationLongitude,
        'clientId': clientId,
        // Wire key is 'assets' — mirrors the Business API's UpdateTransactionRequest.Assets.
        'assets': eventAssets.map((asset) => asset.toJson()).toList(),
      };
}
