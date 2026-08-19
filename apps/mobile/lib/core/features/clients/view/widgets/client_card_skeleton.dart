import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/core/features/clients/models/responses/client_response.dart';
import 'package:business_assistant/core/features/clients/view/client_card.dart';

/// Shimmering placeholder shown while the Clients list is loading — same
/// shape as a real ClientCard, filled with '****'.
class ClientCardSkeleton extends StatelessWidget {
  const ClientCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholder = ClientResponse(id: '****', name: '****', phoneNumber: '****', email: '****');

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ClientCard(client: placeholder, onTap: () {}),
      ),
    );
  }
}
