import 'package:flutter/material.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/shared/widgets/cards/selectable_item.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// One row on the Clients list — wraps SelectableItem with client-specific
/// content (address/phone/email as the subtitle).
class ClientCard extends StatelessWidget {
  final ClientResponse client;
  final VoidCallback onTap;
  final bool isBottomBorderVisible;

  const ClientCard({super.key, required this.client, required this.onTap, this.isBottomBorderVisible = true});

  String get _subtitle {
    final lines = [
      if ((client.locationAddress ?? '').isNotEmpty) client.locationAddress,
      if (client.phoneNumber.isNotEmpty) client.phoneNumber,
      if (client.email.isNotEmpty) client.email,
    ];
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectableItem(
          title: client.name,
          subtitle: _subtitle,
          textColor: context.colors.primaryText,
          fontSize: 16,
          itemPressed: onTap,
        ),
        if (isBottomBorderVisible) Divider(height: 1, color: context.colors.primaryText.withValues(alpha: 0.09)),
      ],
    );
  }
}
