import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:business_assistant/config/translations/enums/language.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';

/// Lets the user pick the app language from [Language.values]. Shows the
/// currently selected language's flag with a chevron, opening a menu of the
/// available options on tap.
///
/// Unlike Zepp's LanguageSelector, this switches immediately with no server
/// call and no auth split — this project doesn't persist a user's preferred
/// language server-side yet.
class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectLanguage(Language language) {
    if (language.value != TranslationStorage().selectedLanguage) {
      TranslationStorage().changeLanguage(language.value);
    }
    _removeOverlay();
    setState(() {});
  }

  OverlayEntry _buildOverlayEntry() {
    final theme = context.colors;

    return OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _removeOverlay)),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 3),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: theme.baseWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: AppColors.primaryShadowColor, blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final language in Language.values)
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _selectLanguage(language),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: SvgPicture.asset(language.flagAsset, width: 20, height: 20, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 10),
                                Text(language.label, style: TextStyle(color: theme.primaryText)),
                                if (language.value == TranslationStorage().selectedLanguage) ...[
                                  const Spacer(),
                                  Icon(Icons.check, size: 18, color: theme.brandPrimary),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final current = Language.values.firstWhere(
      (language) => language.value == TranslationStorage().selectedLanguage,
      orElse: () => Language.english,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.baseWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: AppColors.primaryShadowColor, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(child: SvgPicture.asset(current.flagAsset, width: 20, height: 20, fit: BoxFit.cover)),
              const SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, size: 18, color: theme.primaryText.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
