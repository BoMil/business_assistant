import 'package:flutter/material.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/routes/router_config.dart';
import 'package:business_assistant/config/tenant/tenant_modules.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/account/view/account_page.dart';
import 'package:business_assistant/core/features/clients/view/clients_page.dart';
import 'package:business_assistant/core/features/events/view/events_page.dart';
import 'package:business_assistant/core/features/inventory/view/inventory_page.dart';

/// One entry in the bottom navigation bar.
class BottomNavTab {
  final String path;
  final String svgIconPath;
  final String label;
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder pageBuilder;

  const BottomNavTab({
    required this.path,
    required this.svgIconPath,
    required this.label,
    required this.navigatorKey,
    required this.pageBuilder,
  });
}

/// The bottom nav is built from TenantModules, not TenantType directly — the
/// type only seeds the modules' defaults when a tenant is created (see the
/// backend's TenantModules.CreateDefaults). Each module is independent, so any
/// combination can be toggled per-tenant afterwards.
///
/// Modules are compile-time constants (--dart-define-from-file), so this list
/// is effectively fixed for the lifetime of a given build — it doesn't change
/// at runtime.
List<BottomNavTab> visibleBottomNavTabs() {
  final modules = TenantModules();
  final t = TranslationStorage.translation;

  return [
    if (modules.events)
      BottomNavTab(
        path: RouteNames.eventsPage,
        svgIconPath: 'assets/svg/bottom_nav_events.svg',
        label: t.navEvents,
        navigatorKey: RouterState().eventsNavigatorKey,
        pageBuilder: (_) => const EventsPage(),
      ),
    if (modules.inventory)
      BottomNavTab(
        path: RouteNames.inventoryPage,
        svgIconPath: 'assets/svg/bottom_nav_inventory.svg',
        label: t.navInventory,
        navigatorKey: RouterState().inventoryNavigatorKey,
        pageBuilder: (_) => const InventoryPage(),
      ),
    if (modules.clients)
      BottomNavTab(
        path: RouteNames.clientsPage,
        svgIconPath: 'assets/svg/bottom_nav_clients.svg',
        label: t.navClients,
        navigatorKey: RouterState().clientsNavigatorKey,
        pageBuilder: (_) => const ClientsPage(),
      ),
    // Always visible, regardless of TenantModules.
    BottomNavTab(
      path: RouteNames.accountPage,
      svgIconPath: 'assets/svg/bottom_nav_account.svg',
      label: t.navAccount,
      navigatorKey: RouterState().accountNavigatorKey,
      pageBuilder: (_) => const AccountPage(),
    ),
  ];
}

/// Where an authenticated user lands — the first tab this build actually has.
/// Falls back to the landing page in the (invalid-config) case where no tabs
/// are enabled at all.
String defaultAuthenticatedRoute() {
  final tabs = visibleBottomNavTabs();
  return tabs.isEmpty ? RouteNames.loginPage : tabs.first.path;
}
