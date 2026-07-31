import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_status_badge.dart';
import 'package:business_assistant/core/shared/widgets/cards/selectable_item.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// One row on the Events list — wraps SelectableItem with event-specific
/// content (location/dates/products as the subtitle, price + status on the right).
class EventCard extends StatelessWidget {
  final EventResponse event;
  final VoidCallback onTap;
  final bool isBottomBorderVisible;

  const EventCard({super.key, required this.event, required this.onTap, this.isBottomBorderVisible = true});

  static final _dateFormat = DateFormat('dd.MM.yyyy');

  String get _dateRange {
    if (event.from == null || event.to == null) return '';
    return '${_dateFormat.format(event.from!)} - ${_dateFormat.format(event.to!)}';
  }

  String get _subtitle {
    final lines = [
      if ((event.locationAddress ?? '').isNotEmpty) event.locationAddress,
      if (_dateRange.isNotEmpty) _dateRange,
      if (event.lineItems.isNotEmpty) event.lineItems.map((li) => li.assetName).join(', '),
    ];
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectableItem(
          // borderColor: context.colors.primaryText.withValues(alpha: 0.09),
          title: event.title,
          subtitle: _subtitle,
          textColor: context.colors.primaryText,
          fontSize: 16,
          itemPressed: onTap,
          rightContent: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.totalPrice.toStringAsFixed(0),
                style: TextStyle(color: context.colors.primaryText, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (event.status != null) ...[const SizedBox(height: 6), EventStatusBadge(status: event.status!)],
            ],
          ),
        ),
        if (isBottomBorderVisible) Divider(height: 1, color: context.colors.primaryText.withValues(alpha: 0.09)),
      ],
    );
  }
}
