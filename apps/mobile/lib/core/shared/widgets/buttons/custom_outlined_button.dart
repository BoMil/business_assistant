import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:business_assistant/theme/text_styles.dart';
import 'package:business_assistant/theme/theme_color.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.onClick,
    this.size,
    this.title,
    this.onClickAsync,
    this.child,
    this.width,
    this.height = 50,
    this.radius = 100,
    this.color = AppColors.baseWhite,
    this.borderColor = Colors.transparent,
    this.backgroundColor,
    this.padding,
    this.buttonTextStyle,
    this.borderWidth = 1,
    this.gradient,
    this.isGradientVisible = false,
  });

  final String? title;
  final VoidCallback? onClick;
  final AsyncCallback? onClickAsync;
  final Size? size;
  final Widget? child;
  final double? width;
  final double borderWidth;
  final double height;
  final double? radius;
  final Color color;
  final Color borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? buttonTextStyle;
  final LinearGradient? gradient;
  final bool isGradientVisible;

  @override
  Widget build(BuildContext context) {
    Color bgColor = backgroundColor ?? AppColors.brandPrimary;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 5),
        gradient: isGradientVisible
            ? (gradient ??
                LinearGradient(
                  colors: [
                    AppColors.brandPrimary,
                    AppColors.brandAccent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ))
            : null,
      ),
      child: OutlinedButton(
        onPressed: onClickAsync ?? onClick,
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: borderWidth, color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 5)),
          fixedSize: size,
          textStyle: AppTextStyles().buttonsText(),
          backgroundColor: !isGradientVisible ? (onClick == null ? bgColor.withValues(alpha: 0.4) : bgColor) : null,
          padding: padding,
        ),
        child: child ??
            Text(
              '$title',
              textAlign: TextAlign.center,
              style: buttonTextStyle ?? AppTextStyles().buttonsText(color: color),
            ),
      ),
    );
  }
}
