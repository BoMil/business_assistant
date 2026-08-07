import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/responses/event_asset_response.dart';

/// Mirrors the Business API's TransactionDto. `status` is only meaningful for
/// TransactionType.Rental (the only type this app creates) — it is derived
/// server-side from from/to against "now", never set by the client.
class EventResponse {
  final String id;
  final String title;
  final String? description;
  final DateTime? from;
  final DateTime? to;
  final String? locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? clientId;
  final EventStatus? status;
  final List<EventAssetResponse> eventAssets;

  EventResponse({
    required this.id,
    required this.title,
    this.description,
    this.from,
    this.to,
    this.locationAddress,
    this.locationLatitude,
    this.locationLongitude,
    this.clientId,
    this.status,
    this.eventAssets = const [],
  });

  /// Sum of quantity * price across all event assets — shown as the event's price.
  double get totalPrice => eventAssets.fold(0, (sum, asset) => sum + asset.quantity * asset.price);

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      from: json['from'] != null ? DateTime.parse(json['from'] as String) : null,
      to: json['to'] != null ? DateTime.parse(json['to'] as String) : null,
      locationAddress: json['locationAddress'] as String?,
      locationLatitude: (json['locationLatitude'] as num?)?.toDouble(),
      locationLongitude: (json['locationLongitude'] as num?)?.toDouble(),
      clientId: json['clientId'] as String?,
      status: eventStatusFromJson(json['status'] as String?),
      // Wire key is 'assets' — mirrors the Business API's TransactionDto.Assets.
      eventAssets: (json['assets'] as List? ?? [])
          .map((asset) => EventAssetResponse.fromJson(asset as Map<String, dynamic>))
          .toList(),
    );
  }
}
