import 'package:flutter/material.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/events/cubits/create_edit_event/create_edit_event_cubit.dart';
import 'package:business_assistant/core/shared/widgets/buttons/switch_button.dart';
import 'package:business_assistant/core/shared/widgets/cards/card_frame.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/input_label.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// One added additional-cost row on CreateEditEventPage — editable name/cost
/// plus the isIncludedInTotalCost switch, and a remove button. Keep this
/// widget keyed by localId in its parent ListView so its controllers survive
/// cubit rebuilds.
class EventCostTile extends StatefulWidget {
  final EventFormCost item;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<double> onCostChanged;
  final ValueChanged<bool> onIncludedChanged;
  final VoidCallback onRemove;

  const EventCostTile({
    super.key,
    required this.item,
    required this.onTitleChanged,
    required this.onCostChanged,
    required this.onIncludedChanged,
    required this.onRemove,
  });

  @override
  State<EventCostTile> createState() => _EventCostTileState();
}

class _EventCostTileState extends State<EventCostTile> {
  late final TextEditingController _titleController = TextEditingController(text: widget.item.title);
  late final TextEditingController _costController = TextEditingController(
    text: widget.item.cost % 1 == 0 ? widget.item.cost.toStringAsFixed(0) : widget.item.cost.toString(),
  );

  @override
  void dispose() {
    _titleController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final t = TranslationStorage.translation;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardFrame(
        headerSectionRightContent: InkWell(
          onTap: widget.onRemove,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close, size: 18, color: theme.primaryText.withValues(alpha: 0.5)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputLabel(text: t.eventCostNameLabel),
                      const SizedBox(height: 4),
                      PrimaryInputField(
                        controller: _titleController,
                        showValidationError: false,
                        minContainerHeight: 0,
                        onChanged: widget.onTitleChanged,
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
                        controller: _costController,
                        showValidationError: false,
                        minContainerHeight: 0,
                        keyboardType: TextInputType.number,
                        isCurrency: true,
                        onChanged: (value) => widget.onCostChanged(double.tryParse(value) ?? 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.eventCostIncludedLabel,
                    style: TextStyle(color: theme.primaryText, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                SwitchButton(isActive: widget.item.isIncludedInTotalCost, onChanged: widget.onIncludedChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
