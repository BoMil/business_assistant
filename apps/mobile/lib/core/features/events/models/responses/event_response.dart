import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/responses/event_line_item_response.dart';

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
  final List<EventLineItemResponse> lineItems;

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
    this.lineItems = const [],
  });

  /// Sum of quantity * price across all line items — shown as the event's price.
  double get totalPrice => lineItems.fold(0, (sum, li) => sum + li.quantity * li.price);

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
      lineItems: (json['lineItems'] as List? ?? [])
          .map((li) => EventLineItemResponse.fromJson(li as Map<String, dynamic>))
          .toList(),
    );
  }
}
