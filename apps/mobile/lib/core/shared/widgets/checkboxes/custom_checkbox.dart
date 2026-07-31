import 'package:flutter/material.dart';
import 'package:business_assistant/core/shared/enums/checkbox_shape.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

class CustomCheckbox extends StatelessWidget {
  final double borderRadius;
  final double seletableAreaRadius;
  final Widget? labelWidget;
  final Function(bool isChecked) itemPressed;
  final Color? backgroundColor;
  final double fontSize;
  final bool isChecked;
  final CheckboxShape checkboxShape;

  const CustomCheckbox({
    super.key,
    required this.itemPressed,
    this.borderRadius = 2,
    this.seletableAreaRadius = 6,
    this.labelWidget,
    this.backgroundColor,
    this.fontSize = 11,
    this.isChecked = false,
    this.checkboxShape = CheckboxShape.square,
  });

  void _toggleCheckbox(BuildContext context) {
    bool newValue = !isChecked;
    itemPressed.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(seletableAreaRadius)),
      ),
      child: Material(
        color: backgroundColor ?? theme.secondaryBackground,
        borderRadius: BorderRadius.circular(seletableAreaRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(seletableAreaRadius),
          onTap: () => _toggleCheckbox(context),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 16,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isChecked ? theme.brandPrimary : theme.primaryText.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  color: isChecked ? theme.brandPrimary : theme.baseWhite,
                  borderRadius: BorderRadius.circular(checkboxShape == CheckboxShape.square ? borderRadius : 100),
                ),
                child: checkboxShape == CheckboxShape.radio
                    ? (isChecked
                        ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: theme.baseWhite, shape: BoxShape.circle),
                            ),
                          )
                        : null)
                    : Icon(Icons.check_rounded, size: 10, color: theme.baseWhite),
              ),
              if (labelWidget != null) ...[const SizedBox(width: 8), labelWidget!],
            ],
          ),
        ),
      ),
    );
  }
}
