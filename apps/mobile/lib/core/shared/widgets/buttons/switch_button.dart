import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SwitchButtonType { primary, secondary }

class SwitchButton extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool>? onChanged;
  final SwitchButtonType type;
  final bool isLoading;

  const SwitchButton({
    super.key,
    required this.isActive,
    required this.onChanged,
    this.type = SwitchButtonType.primary,
    this.isLoading = false,
  });

  _getSwitchButton(BuildContext context) {
    final theme = context.colors;

    switch (type) {
      case SwitchButtonType.primary:
        return Opacity(
          opacity: isLoading ? 0.5 : 1,
          child: Switch(
            value: isActive,
            onChanged: isLoading ? null : onChanged,
            activeThumbColor: theme.brandPrimary,
            activeTrackColor: theme.secondaryGray,
            inactiveTrackColor: theme.secondaryGray,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              // if (states.contains(WidgetState.selected)) {
              //   return AppColors.appPrimaryColor;
              // }
              return theme.primaryText.withValues(alpha: 0.05);
            }),
            trackOutlineWidth: WidgetStateProperty.all(1.0),
          ),
        );
      case SwitchButtonType.secondary:
        return Opacity(
          opacity: isLoading ? 0.5 : 1,
          child: Switch(
            value: isActive,
            onChanged: onChanged,
            activeThumbColor: theme.baseWhite,
            activeTrackColor: AppColors.switchRed,
            inactiveTrackColor: theme.secondaryGray,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              // if (states.contains(WidgetState.selected)) {
              //   return AppColors.appPrimaryColor;
              // }
              return theme.primaryText.withValues(alpha: 0.05);
            }),
            trackOutlineWidth: WidgetStateProperty.all(1.0),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _getSwitchButton(context),
        if (isLoading) ...[
          Positioned(right: 20, bottom: 13, child: CupertinoActivityIndicator(color: AppColors.darkOrange)),
        ],
      ],
    );
  }
}
