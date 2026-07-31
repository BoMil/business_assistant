import 'package:business_assistant/core/features/events/models/requests/event_line_item_request.dart';

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
  final List<EventLineItemRequest> lineItems;

  const UpdateEventRequest({
    required this.title,
    required this.from,
    required this.to,
    required this.locationAddress,
    this.description,
    this.locationLatitude,
    this.locationLongitude,
    this.clientId,
    this.lineItems = const [],
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
        'lineItems': lineItems.map((li) => li.toJson()).toList(),
      };
}
