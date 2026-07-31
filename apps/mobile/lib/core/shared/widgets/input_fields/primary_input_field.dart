import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_config.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/input_label.dart';
import 'package:business_assistant/theme/input_styles.dart';
import 'package:business_assistant/theme/text_styles.dart';
import 'package:business_assistant/theme/theme_color.dart';

class PrimaryInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? errorMsg;
  final bool? readOnly;
  final Function(String)? onChanged;
  final Widget? sufixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final int? areaField;
  final bool passwordFieldVisible;
  final Color labelColor;
  final EdgeInsetsGeometry contentPadding;
  final String placeholderText;
  final String hintText;
  final Color? inputBackgroundCollor;
  final double minContainerHeight;
  final String? Function(String? value)? customValidator;
  final bool autoValidate;
  final bool floatLabelToTop;
  final bool enabled;
  final Function(bool)? onFocusChanged;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isCurrency;
  final String? regularExpression;
  final String? initialValue;
  final bool showValidationError;

  const PrimaryInputField({
    super.key,
    required this.controller,
    this.labelText,
    this.errorMsg,
    this.readOnly,
    this.onChanged,
    this.sufixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.areaField,
    this.labelColor = AppColors.primaryText,
    this.passwordFieldVisible = false,
    this.placeholderText = '',
    this.hintText = '',
    this.contentPadding = const EdgeInsets.only(bottom: 9, left: 7, top: 9),
    this.inputBackgroundCollor,
    this.minContainerHeight = 83,
    this.customValidator,
    this.autoValidate = false,
    this.floatLabelToTop = false,
    this.onFocusChanged,
    this.enabled = true,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = 10,
    this.isCurrency = false,
    this.regularExpression,
    this.initialValue,
    this.showValidationError = true,
  });

  @override
  State<PrimaryInputField> createState() => _PrimaryInputFieldState();
}

class _PrimaryInputFieldState extends State<PrimaryInputField> {
  final FocusNode _focusNode = FocusNode();
  String? _currentError;

  @override
  void initState() {
    super.initState();
    if (widget.onFocusChanged == null) {
      return;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          if (widget.labelText != null) ...[InputLabel(text: widget.labelText!), const SizedBox(height: 4)],

          // Input field
          TextFormField(
            initialValue: widget.initialValue,
            enabled: widget.enabled,
            focusNode: _focusNode,
            autovalidateMode: widget.autoValidate ? AutovalidateMode.always : null,
            style: AppTextStyles().buttonsText(
              color: ThemeConfig().themeColor.primaryText,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.primaryText,
            obscureText: widget.passwordFieldVisible,
            keyboardType: widget.keyboardType,
            // No whitespace formatter here: trimming per keystroke eats the
            // just-typed trailing space, making spaces impossible to enter.
            // Submitted values are trimmed server-side instead.
            inputFormatters: <TextInputFormatter>[
              if (widget.keyboardType == TextInputType.number && widget.isCurrency) ...[
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9.,]+$')),
              ] else if (widget.keyboardType == TextInputType.number) ...[
                FilteringTextInputFormatter.allow(RegExp(r'^[^a-zA-Z]+$')),
              ],
            ],
            onChanged: (value) => widget.onChanged?.call(value),
            readOnly: widget.readOnly ?? false,
            maxLines: widget.areaField ?? 1,
            controller: widget.controller,
            decoration: InputStyles.primaryInputDecoration(
              lableText: widget.placeholderText,
              hintText: widget.hintText,
              fillColor: widget.inputBackgroundCollor ?? ThemeConfig().themeColor.baseWhite,
              suffix: widget.sufixIcon,
              prefixIcon: widget.prefixIcon,
              contentPadding: widget.contentPadding,
              floatLabelToTop: widget.floatLabelToTop,
              borderColor: widget.borderColor ?? ThemeConfig().themeColor.primaryText.withValues(alpha: 0.15),
              borderWidth: widget.borderWidth,
              borderRadius: widget.borderRadius,
            ).copyWith(
              // The custom error row below (icon + text) is our error display;
              // suppress TextFormField's own auto-rendered error text so it's
              // not shown twice.
              errorStyle: widget.showValidationError ? const TextStyle(fontSize: 0, height: 0.01) : null,
            ),
            validator: (value) {
              String? error;
              if (widget.regularExpression != null && widget.regularExpression!.isNotEmpty) {
                final RegExp regExp = RegExp(widget.regularExpression!);
                if (!regExp.hasMatch(value ?? '')) {
                  error = widget.errorMsg ?? TranslationStorage.translation.fieldDoesntPassRegularExpressionValidation;
                }
              } else if (widget.customValidator != null) {
                error = widget.customValidator!(value);
              } else if (value == null || value.isEmpty) {
                error = widget.errorMsg ?? TranslationStorage.translation.fieldIsRequired;
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _currentError != error) {
                  setState(() => _currentError = error);
                }
              });
              return error;
            },
          ),

          // Custom error row with icon
          if (widget.showValidationError && _currentError != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                SvgPicture.asset('assets/svg/error_info.svg'),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _currentError!,
                    style: AppTextStyles().secondaryText(
                      color: context.colors.brandError,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
