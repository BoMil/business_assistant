import 'package:business_assistant/core/features/events/models/requests/event_asset_request.dart';
import 'package:business_assistant/core/features/events/models/requests/event_cost_request.dart';

/// JSON body for POST /transactions — mirrors the Business API's
/// CreateTransactionRequest. This app only ever creates TransactionType.Rental
/// transactions (the "Event" concept in the Rental UI), so `type` is fixed —
/// see Business.Domain.Enums.TransactionType.
class CreateEventRequest {
  static const String _rentalType = 'Rental';

  final String title;
  final String? description;
  final DateTime from;
  final DateTime to;
  final String locationAddress;
  final double? locationLatitude;
  final double? locationLongitude;
  final String? clientId;
  final List<EventAssetRequest> eventAssets;
  final List<EventCostRequest> eventCosts;

  const CreateEventRequest({
    required this.title,
    required this.from,
    required this.to,
    required this.locationAddress,
    this.description,
    this.locationLatitude,
    this.locationLongitude,
    this.clientId,
    this.eventAssets = const [],
    this.eventCosts = const [],
  });

  Map<String, dynamic> toJson() => {
        'type': _rentalType,
        'title': title,
        'description': description,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'locationAddress': locationAddress,
        'locationLatitude': locationLatitude,
        'locationLongitude': locationLongitude,
        'clientId': clientId,
        // Wire key is 'assets' — mirrors the Business API's CreateTransactionRequest.Assets.
        'assets': eventAssets.map((asset) => asset.toJson()).toList(),
        // Wire key is 'costs' — mirrors the Business API's CreateTransactionRequest.Costs.
        'costs': eventCosts.map((cost) => cost.toJson()).toList(),
      };
}
