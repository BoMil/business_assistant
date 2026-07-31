import 'package:flutter/material.dart';

/// Placeholder for the Account tab — replaced with the real UI later.
///
/// Unlike Events/Inventory/Clients, this tab is always visible regardless of
/// TenantModules — see bottom_nav_tabs.dart.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Account')));
  }
}
