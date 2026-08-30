import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_status_badge.dart';
import 'package:business_assistant/core/features/tenant/cubits/tenant_config/tenant_config_cubit.dart';
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
      if (event.eventAssets.isNotEmpty) event.eventAssets.map((asset) => asset.assetName).join(', '),
    ];
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;
    final currencySymbol = context.read<TenantConfigCubit>().state.currencySymbol;
    final balanceColor = event.netBalance >= 0 ? theme.statusFinished : theme.brandError;

    return Column(
      children: [
        SelectableItem(
          // borderColor: context.colors.primaryText.withValues(alpha: 0.09),
          title: event.title,
          subtitle: _subtitle,
          textColor: theme.primaryText,
          fontSize: 16,
          itemPressed: onTap,
          rightContent: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: theme.primaryText.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: '${t.eventCardBalanceLabel}: '),
                    TextSpan(
                      text:
                          '${event.netBalance % 1 == 0 ? event.netBalance.toStringAsFixed(0) : event.netBalance.toString()} $currencySymbol',
                      style: TextStyle(color: balanceColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: theme.primaryText.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: '${t.eventCardChargedLabel}: '),
                    TextSpan(
                      text:
                          '${event.chargedTotal % 1 == 0 ? event.chargedTotal.toStringAsFixed(0) : event.chargedTotal.toString()} $currencySymbol',
                      style: TextStyle(color: theme.statusFinished),
                    ),
                  ],
                ),
              ),
              if (event.status != null) ...[const SizedBox(height: 6), EventStatusBadge(status: event.status!)],
            ],
          ),
        ),
        if (isBottomBorderVisible) Divider(height: 1, color: theme.primaryText.withValues(alpha: 0.09)),
      ],
    );
  }
}
