import 'package:flutter/material.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// A reusable AppBar used on most full-screen pages.
///
/// The back button calls [backButtonPressed] if provided — if null the button
/// is visible but does nothing (use this on root screens like LandingPage
/// where you don't want to navigate back).
///
/// [actions] accepts any trailing widgets (e.g. an overflow menu button).
class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData icon;
  final Function()? backButtonPressed;
  final List<Widget>? actions;
  final Widget? title;
  final Color? backgroundColor;

  const HeaderBar({
    super.key,
    this.icon = Icons.arrow_back_ios_new,
    this.backButtonPressed,
    this.actions,
    this.title,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ?? getSelectedThemeColors(context).secondaryBackground,
      foregroundColor: AppColors.primaryBackground,
      elevation: 0,
      title: title,
      leading: GestureDetector(
        onTap: () => backButtonPressed?.call(),
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 18.0, bottom: 8),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryText,
              size: 18,
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
