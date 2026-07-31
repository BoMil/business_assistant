import 'package:flutter/material.dart';
import 'package:business_assistant/core/shared/widgets/buttons/custom_outlined_button.dart';
import 'package:business_assistant/theme/theme_color.dart';

class ButtonWithLoadingState extends StatefulWidget {
  final String buttonText;
  final bool? loading;
  final void Function()? buttonPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loaderColor;
  final double? radius;
  final Size? size;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final double height;
  final Widget? child;
  final bool isGradientVisible;
  final TextStyle? buttonTextStyle;

  const ButtonWithLoadingState({
    super.key,
    required this.buttonText,
    this.loading,
    this.buttonPressed,
    this.backgroundColor,
    this.textColor,
    this.loaderColor,
    this.radius = 100,
    this.size,
    this.borderColor = Colors.transparent,
    this.padding,
    this.height = 55,
    this.child,
    this.isGradientVisible = false,
    this.buttonTextStyle,
  });

  @override
  State<ButtonWithLoadingState> createState() => ButtonWithLoadingStateState();
}

class ButtonWithLoadingStateState extends State<ButtonWithLoadingState> {
  bool isLoading = false;

  setLoadingIndicator(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomOutlinedButton(
      isGradientVisible: widget.isGradientVisible,
      buttonTextStyle: widget.buttonTextStyle,
      padding: widget.padding,
      height: widget.height,
      borderColor: widget.borderColor,
      backgroundColor: widget.backgroundColor ?? AppColors.brandPrimary,
      color: widget.textColor ?? AppColors.baseWhite,
      title: widget.buttonText,
      size: widget.size ?? Size(MediaQuery.sizeOf(context).width, 50),
      radius: widget.radius,
      onClick: widget.buttonPressed == null
          ? null
          : () {
              if (widget.loading ?? isLoading) {
                return;
              }
              widget.buttonPressed!();
            },
      child: (widget.loading ?? isLoading)
          ? Image.asset('assets/gifs/loader.gif', height: 30, width: 30, fit: BoxFit.contain)
          : widget.child,
    );
  }
}
