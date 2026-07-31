import 'package:flutter/material.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// A numeric field with +/- stepper buttons — used for "Number to rent"
/// style quantity inputs.
class NumberStepperInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int min;

  const NumberStepperInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.min = 1,
  });

  void _step(int delta) {
    final current = int.tryParse(controller.text) ?? min;
    final next = (current + delta).clamp(min, 1 << 30).toString();
    controller.text = next;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PrimaryInputField(
              showValidationError: false,
              minContainerHeight: 0,
              keyboardType: TextInputType.number,
              placeholderText: '$min',
              onChanged: onChanged,
              controller: controller,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: theme.primaryText.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => _step(-1),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text('−', style: TextStyle(fontSize: 20, color: theme.primaryText.withValues(alpha: 0.5))),
                    ),
                  ),
                ),
                Center(
                  child: FractionallySizedBox(
                    heightFactor: 0.5,
                    child: Container(width: 1, color: theme.primaryText.withValues(alpha: 0.2)),
                  ),
                ),
                InkWell(
                  onTap: () => _step(1),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text('+', style: TextStyle(fontSize: 20, color: theme.primaryText.withValues(alpha: 0.5))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
