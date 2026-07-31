import 'package:business_assistant/core/shared/widgets/input_fields/location_input_field.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';
import 'package:flutter/material.dart';

class LocationAutoCompleteMenu extends StatelessWidget {
  final LocationPrediction prediction;
  const LocationAutoCompleteMenu({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.baseWhite),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.location_on, color: context.colors.brandPrimary),
          const SizedBox(width: 7),
          Expanded(child: Text(prediction.description, style: TextStyle(color: context.colors.primaryText))),
        ],
      ),
    );
  }
}
