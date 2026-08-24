import 'dart:convert';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/routes/router_config.dart';
import 'package:business_assistant/config/routes/routes.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/clients/models/page_props/create_edit_client_page_props.dart';
import 'package:business_assistant/core/features/events/models/page_props/create_edit_event_page_props.dart';
import 'package:business_assistant/core/features/inventory/models/page_props/create_edit_asset_page_props.dart';
import 'package:business_assistant/core/features/push_notifications/models/push_action.dart';
import 'package:business_assistant/core/features/push_notifications/models/push_entity_type.dart';

/// Routes a tapped push notification to the relevant entity's edit/detail page
/// (there is no separate read-only detail page — the edit page doubles as one).
/// Called from every tap entry point: a foreground local notification tap,
/// a background FCM tap (onMessageOpenedApp), and a cold-start FCM tap
/// (getInitialMessage, handled by MyApp once auth state is known).
class PushNotificationRouter {
  /// Set from `getInitialMessage()` at app boot if the app was launched by
  /// tapping a notification. Consumed once auth state resolves, since
  /// RouterState().authCubit isn't ready yet at that point in startup.
  static Map<String, dynamic>? pendingColdStartData;

  static void handleTap(Map<String, dynamic> data) {
    if (RouterState().authCubit.state is! Authenticated) return;

    final entityType = PushEntityType.fromWireName(data['entityType'] as String?);
    final action = PushAction.fromWireName(data['action'] as String?);
    final entityId = data['entityId'] as String?;

    if (entityType == null || action == null || entityId == null) return;
    // Nothing to open for a deleted entity — its edit page no longer applies.
    if (action == PushAction.deleted) return;

    switch (entityType) {
      case PushEntityType.transaction:
        Routes().goRouterInstance.push(RouteNames.editEventPage, extra: CreateEditEventPageProps(eventId: entityId));
      case PushEntityType.asset:
        Routes().goRouterInstance.push(RouteNames.editAssetPage, extra: CreateEditAssetPageProps(assetId: entityId));
      case PushEntityType.client:
        Routes().goRouterInstance.push(RouteNames.editClientPage, extra: CreateEditClientPageProps(clientId: entityId));
    }
  }

  /// flutter_local_notifications only supports a flat String payload, so the
  /// data map is JSON-encoded when the local notification is shown.
  static void handleLocalNotificationPayload(String? payload) {
    if (payload == null) return;
    handleTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
  }
}
