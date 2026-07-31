import 'package:flutter/material.dart';
import 'package:business_assistant/core/features/events/cubits/create_edit_event/create_edit_event_cubit.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/number_stepper_input_field.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// One added product row on CreateEditEventPage — editable quantity + price,
/// plus a remove button. Keep this widget keyed by assetId in its parent
/// ListView so its controllers survive cubit rebuilds.
class EventLineItemTile extends StatefulWidget {
  final EventFormLineItem item;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onRemove;

  const EventLineItemTile({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  @override
  State<EventLineItemTile> createState() => _EventLineItemTileState();
}

class _EventLineItemTileState extends State<EventLineItemTile> {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryText.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.assetName,
                  style: TextStyle(color: theme.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: widget.onRemove,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18, color: theme.primaryText.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NumberStepperInputField(
                  controller: _quantityController,
                  onChanged: (value) => widget.onQuantityChanged(int.tryParse(value) ?? 1),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: PrimaryInputField(
                  controller: _priceController,
                  showValidationError: false,
                  minContainerHeight: 0,
                  keyboardType: TextInputType.number,
                  isCurrency: true,
                  onChanged: (value) => widget.onPriceChanged(double.tryParse(value) ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
