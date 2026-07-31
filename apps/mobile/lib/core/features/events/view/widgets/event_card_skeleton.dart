import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/core/features/events/models/enums/event_status.dart';
import 'package:business_assistant/core/features/events/models/responses/event_line_item_response.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/events/view/event_card.dart';

/// Shimmering placeholder shown at the bottom of the Events list while a
/// page is loading — same shape as a real EventCard, filled with '****'.
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholder = EventResponse(
      id: '****',
      title: '****',
      locationAddress: '****',
      from: DateTime(2026, 1, 1),
      to: DateTime(2026, 1, 2),
      status: EventStatus.pending,
      lineItems: [EventLineItemResponse(assetId: '****', assetName: '****', quantity: 1, price: 0)],
    );

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: EventCard(event: placeholder, onTap: () {}),
      ),
    );
  }
}
