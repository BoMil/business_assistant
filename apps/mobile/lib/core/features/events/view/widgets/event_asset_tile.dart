import 'package:flutter/material.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/cubits/create_edit_event/create_edit_event_cubit.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/input_label.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/number_stepper_input_field.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// One added product row on CreateEditEventPage — editable quantity + price,
/// plus a remove button. Keep this widget keyed by assetId in its parent
/// ListView so its controllers survive cubit rebuilds.
class EventAssetTile extends StatefulWidget {
  final EventFormAsset item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onRemove;

  const EventAssetTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  @override
  State<EventAssetTile> createState() => _EventAssetTileState();
}

class _EventAssetTileState extends State<EventAssetTile> {
  late final TextEditingController _quantityController =
      TextEditingController(text: widget.item.quantity.toString());
  late final TextEditingController _priceController =
      TextEditingController(text: widget.item.price.toStringAsFixed(0));

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final t = TranslationStorage.translation;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardFrame(
        headerSectionTtitle: widget.item.assetName,
        headerSectionRightContent: InkWell(
          onTap: widget.onRemove,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close, size: 18, color: theme.primaryText.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputLabel(text: t.eventAssetQuantityLabel),
                  const SizedBox(height: 4),
                  NumberStepperInputField(
                    controller: _quantityController,
                    onChanged: (value) => widget.onQuantityChanged(int.tryParse(value) ?? 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputLabel(text: t.eventAssetPriceLabel),
                  const SizedBox(height: 4),
                  PrimaryInputField(
                    controller: _priceController,
                    showValidationError: false,
                    minContainerHeight: 0,
                    keyboardType: TextInputType.number,
                    isCurrency: true,
                    onChanged: (value) => widget.onPriceChanged(double.tryParse(value) ?? 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
