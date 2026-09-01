import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/clients/models/page_props/create_edit_client_page_props.dart';
import 'package:business_assistant/core/features/events/cubits/event_preview_page/event_preview_page_cubit.dart';
import 'package:business_assistant/core/features/events/models/page_props/create_edit_event_page_props.dart';
import 'package:business_assistant/core/features/events/models/page_props/event_preview_page_props.dart';
import 'package:business_assistant/core/features/events/models/responses/event_asset_response.dart';
import 'package:business_assistant/core/features/events/models/responses/event_cost_response.dart';
import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/features/events/view/widgets/event_status_badge.dart';
import 'package:business_assistant/core/features/tenant/cubits/tenant_config/tenant_config_cubit.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/buttons/custom_outlined_button.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/utils/launcher.dart';
import 'package:business_assistant/l10n/app_localizations.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';
import 'package:business_assistant/theme/theme_constants.dart';

/// Read-only detail view for an event, reached from ClientEventsPage/EventsPage.
/// Shows the same data CreateEditEventPage collects, but without the form —
/// the "Edit" button at the bottom pushes CreateEditEventPage for actual
/// editing. When the caller didn't already pass the client's name (EventsPage
/// doesn't have it), EventPreviewPageCubit fetches it by pageProps.event.clientId.
class EventPreviewPage extends StatelessWidget {
  final EventPreviewPageProps? pageProps;

  const EventPreviewPage({super.key, this.pageProps});

  @override
  Widget build(BuildContext context) {
    final clientId = pageProps?.event.clientId;
    final needsClientFetch = clientId != null && (pageProps?.clientName ?? '').isEmpty;
    return BlocProvider<EventPreviewPageCubit>(
      create: (_) {
        final cubit = EventPreviewPageCubit();
        if (needsClientFetch) cubit.loadClient(clientId);
        return cubit;
      },
      child: _EventPreviewPageContent(pageProps: pageProps),
    );
  }
}

class _EventPreviewPageContent extends StatelessWidget {
  final EventPreviewPageProps? pageProps;

  const _EventPreviewPageContent({this.pageProps});

  static final _dateFormat = DateFormat('dd.MM.yyyy');

  String _dateRange(EventResponse event) {
    if (event.from == null || event.to == null) return '';
    return '${_dateFormat.format(event.from!)} - ${_dateFormat.format(event.to!)}';
  }

  Widget _buildDetailRow(ThemeColor theme, String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.primaryText.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Flexible(child: Align(alignment: Alignment.centerRight, child: value)),
      ],
    );
  }

  Widget _buildTextValue(ThemeColor theme, String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDivider(ThemeColor theme) => Divider(height: 20, color: theme.primaryText.withValues(alpha: 0.08));

  void _openInMaps(double? latitude, double? longitude, String address) {
    final query = latitude != null && longitude != null ? '$latitude,$longitude' : address;
    final uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});
    launchWebUrl(uri.toString());
  }

  Widget _buildClientRow(BuildContext context, ThemeColor theme, AppLocalizations t, String clientId, String? knownClientName) {
    return BlocBuilder<EventPreviewPageCubit, EventPreviewPageState>(
      builder: (context, state) {
        final resolvedName = knownClientName ?? state.client?.name;
        final isLoading = knownClientName == null && state.clientState != CubitState.loaded && state.clientState != CubitState.error;
        if (!isLoading && resolvedName == null) return const SizedBox.shrink();
        return Column(
          children: [
            _buildDivider(theme),
            Skeletonizer(
              enabled: isLoading,
              child: GestureDetector(
                onTap: () => context.push(RouteNames.editClientPage, extra: CreateEditClientPageProps(clientId: clientId)),
                child: _buildDetailRow(theme, t.eventClientLabel, _buildTextValue(theme, resolvedName ?? 'Client name')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductRow(ThemeColor theme, EventAssetResponse asset, String currencySymbol) {
    final lineTotal = asset.price * asset.quantity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${asset.assetName} ×${asset.quantity}',
            style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '${lineTotal % 1 == 0 ? lineTotal.toStringAsFixed(0) : lineTotal.toString()} $currencySymbol',
          style: TextStyle(color: theme.statusFinished, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildCostRow(ThemeColor theme, EventCostResponse cost, String currencySymbol) {
    final color = cost.isIncludedInTotalCost ? theme.statusFinished : theme.brandError;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            cost.title,
            style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '${cost.cost % 1 == 0 ? cost.cost.toStringAsFixed(0) : cost.cost.toString()} $currencySymbol',
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildBalanceSection(EventResponse event, ThemeColor theme, String currencySymbol, AppLocalizations t) {
    final assetsValue = event.eventAssets.fold<double>(0, (sum, ea) => sum + ea.price * ea.quantity);
    final includedCosts = event.eventCosts
        .where((ec) => ec.isIncludedInTotalCost)
        .fold<double>(0, (sum, ec) => sum + ec.cost);
    final extraCosts = event.eventCosts
        .where((ec) => !ec.isIncludedInTotalCost)
        .fold<double>(0, (sum, ec) => sum + ec.cost);
    final netBalance = assetsValue - extraCosts;

    return CardFrame(
      headerSectionTtitle: t.eventBalanceTitle,
      child: Column(
        children: [
          _buildBalanceRow(theme, t.eventBalanceAssetsValueLabel, assetsValue, theme.statusFinished, currencySymbol),
          _buildDivider(theme),
          _buildBalanceRow(
            theme,
            t.eventBalanceIncludedCostsLabel,
            includedCosts,
            theme.statusFinished,
            currencySymbol,
          ),
          _buildDivider(theme),
          _buildBalanceRow(theme, t.eventBalanceExtraCostsLabel, extraCosts, theme.brandError, currencySymbol),
          _buildDivider(theme),
          _buildBalanceRow(
            theme,
            t.eventBalanceTotalLabel,
            netBalance,
            netBalance >= 0 ? theme.statusFinished : theme.brandError,
            currencySymbol,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
    ThemeColor theme,
    String label,
    double value,
    Color valueColor,
    String currencySymbol, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.primaryText,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          '${value % 1 == 0 ? value.toStringAsFixed(0) : value.toString()} $currencySymbol',
          style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final theme = context.colors;
    final currencySymbol = context.read<TenantConfigCubit>().state.currencySymbol;
    final event = pageProps?.event;
    final clientName = pageProps?.clientName;

    if (event == null) {
      return const PageFrame(headerActionIcon: Icons.close, pageBody: SizedBox.shrink());
    }

    final dateRange = _dateRange(event);

    return PageFrame(
      headerActionIcon: Icons.close,
      headerActions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${event.chargedTotal % 1 == 0 ? event.chargedTotal.toStringAsFixed(0) : event.chargedTotal.toString()} $currencySymbol',
              style: TextStyle(color: theme.statusFinished, fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
      title: Text(
        t.eventDetailsTitle,
        style: TextStyle(color: theme.primaryText, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      pageBody: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Details
            const SizedBox(height: 16),
            CardFrame(
              child: Column(
                children: [
                  if (event.status != null) ...[
                    _buildDetailRow(theme, t.eventStatusLabel, EventStatusBadge(status: event.status!)),
                    _buildDivider(theme),
                  ],
                  _buildDetailRow(theme, t.eventTitleLabel, _buildTextValue(theme, event.title)),
                  if (event.clientId != null) _buildClientRow(context, theme, t, event.clientId!, clientName),
                  if (dateRange.isNotEmpty) ...[
                    _buildDivider(theme),
                    _buildDetailRow(theme, t.eventDateRangeLabel, _buildTextValue(theme, dateRange)),
                  ],
                  if ((event.locationAddress ?? '').trim().isNotEmpty) ...[
                    _buildDivider(theme),
                    GestureDetector(
                      onTap:
                          () => _openInMaps(
                            event.locationLatitude,
                            event.locationLongitude,
                            event.locationAddress!.trim(),
                          ),
                      child: _buildDetailRow(
                        theme,
                        t.eventLocationLabel,
                        _buildTextValue(theme, event.locationAddress!.trim()),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed:
                            () => _openInMaps(
                              event.locationLatitude,
                              event.locationLongitude,
                              event.locationAddress!.trim(),
                            ),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: Text(t.eventViewOnMapLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Assets
            if (event.eventAssets.isNotEmpty) ...[
              const SizedBox(height: 12),
              CardFrame(
                headerSectionTtitle: t.eventProductsLabel,
                child: Column(
                  children: [
                    for (var i = 0; i < event.eventAssets.length; i++) ...[
                      if (i > 0) _buildDivider(theme),
                      _buildProductRow(theme, event.eventAssets[i], currencySymbol),
                    ],
                  ],
                ),
              ),
            ],

            // Description
            if ((event.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              CardFrame(
                headerSectionTtitle: t.eventDescriptionLabel,
                child: Text(event.description!.trim(), style: TextStyle(color: theme.primaryText, fontSize: 14)),
              ),
            ],

            // Costs
            if (event.eventCosts.isNotEmpty) ...[
              const SizedBox(height: 12),
              CardFrame(
                headerSectionTtitle: t.eventCostsLabel,
                child: Column(
                  children: [
                    for (var i = 0; i < event.eventCosts.length; i++) ...[
                      if (i > 0) _buildDivider(theme),
                      _buildCostRow(theme, event.eventCosts[i], currencySymbol),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Balance
            _buildBalanceSection(event, theme, currencySymbol, t),
            const SizedBox(height: 24),
          ],
        ),
      ),
      pageBottomBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(ThemeConstants.pagePadding, 12, ThemeConstants.pagePadding, 16),
          child: CustomOutlinedButton(
            title: t.editEventButton,
            backgroundColor: theme.brandPrimary,
            color: Colors.white,
            onClick: () async {
              final saved = await context.push<bool>(
                RouteNames.editEventPage,
                extra: CreateEditEventPageProps(eventId: event.id, event: event),
              );
              if (saved == true && context.mounted) context.pop(true);
            },
          ),
        ),
      ),
    );
  }
}
