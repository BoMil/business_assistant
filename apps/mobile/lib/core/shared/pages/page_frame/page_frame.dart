import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/core/shared/widgets/screens/header_bar.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_constants.dart';

class PageFrame extends StatelessWidget {
  final Widget pageBody;
  final Function()? backButtonPressed;
  final List<Widget>? headerActions;
  final Widget? title;
  final IconData? headerActionIcon;
  final Widget? pageBottomBar;
  final bool isHeaderVisible;
  final double pagePadding;

  const PageFrame({
    super.key,
    required this.pageBody,
    this.backButtonPressed,
    this.headerActions,
    this.title,
    this.headerActionIcon = Icons.arrow_back_ios_new,
    this.pageBottomBar,
    this.isHeaderVisible = true,
    this.pagePadding = ThemeConstants.pagePadding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Remove focus from the keyboard
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: getSelectedThemeColors(context).primaryBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: isHeaderVisible
              ? HeaderBar(
                  icon: headerActionIcon ?? Icons.arrow_back_ios_new,
                  actions: headerActions,
                  title: title,
                  backgroundColor: Colors.transparent,
                  backButtonPressed: () {
                    if (backButtonPressed == null) {
                      context.pop();
                      return;
                    }
                    backButtonPressed?.call();
                  },
                )
              : null,
          body: Padding(
            padding: EdgeInsets.only(left: pagePadding, right: pagePadding),
            child: pageBody,
          ),
          bottomNavigationBar: pageBottomBar,
        ),
      ),
    );
  }
}
