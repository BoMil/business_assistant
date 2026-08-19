import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/features/inventory/view/asset_card.dart';

/// Shimmering placeholder shown while the Inventory list is loading — same
/// shape as a real AssetCard, filled with '****'.
class AssetCardSkeleton extends StatelessWidget {
  const AssetCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholder = AssetResponse(id: '****', name: '****', categoryName: '****', stockCount: 0, rentalPrice: 0);

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AssetCard(asset: placeholder, onTap: () {}),
      ),
    );
  }
}
