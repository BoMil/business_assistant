import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/features/tenant/cubits/tenant_config/tenant_config_cubit.dart';
import 'package:business_assistant/core/shared/widgets/cards/selectable_item.dart';
import 'package:business_assistant/core/shared/widgets/images/loaded_image.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// One row on the Inventory list — wraps SelectableItem with product-specific
/// content (category as the subtitle, price + stock count on the right).
class AssetCard extends StatelessWidget {
  final AssetResponse asset;
  final VoidCallback onTap;
  final bool isBottomBorderVisible;

  const AssetCard({super.key, required this.asset, required this.onTap, this.isBottomBorderVisible = true});

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final price = asset.rentalPrice ?? asset.salePrice;
    final currencySymbol = context.read<TenantConfigCubit>().state.currencySymbol;

    return Column(
      children: [
        SelectableItem(
          title: asset.name,
          subtitle: asset.categoryName,
          textColor: context.colors.primaryText,
          fontSize: 16,
          itemPressed: onTap,
          leftIcon: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LoadedImage(
              imageUrl: asset.imgUrl ?? '',
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              alternativeWidget: Container(
                width: 44,
                height: 44,
                color: context.colors.secondaryBackground,
                child: Icon(Icons.image_outlined, size: 20, color: context.colors.primaryText.withValues(alpha: 0.3)),
              ),
            ),
          ),
          rightContent: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (price != null)
                Text(
                  '${price % 1 == 0 ? price.toStringAsFixed(0) : price.toString()} $currencySymbol',
                  style: TextStyle(color: context.colors.statusFinished, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              const SizedBox(height: 4),
              Text(
                '${asset.stockCount} ${t.productStockUnitLabel}',
                style: TextStyle(color: context.colors.primaryText.withValues(alpha: 0.5), fontSize: 12),
              ),
            ],
          ),
        ),
        if (isBottomBorderVisible) Divider(height: 1, color: context.colors.primaryText.withValues(alpha: 0.09)),
      ],
    );
  }
}
