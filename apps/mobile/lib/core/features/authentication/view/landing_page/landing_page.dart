import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/tenant/feature_flags.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';
import 'package:business_assistant/config/translations/enums/language.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_color.dart';
import 'package:business_assistant/theme/theme_config.dart';
import 'package:business_assistant/theme/theme_constants.dart';

/// The first screen shown to unauthenticated users.
///
/// Displays:
///   - Tenant logo and app name
///   - Theme toggle (light / dark) — if FEATURE_THEME_CHANGE is enabled
///   - Language toggle (EN / SR) — if FEATURE_LANGUAGE is enabled
///   - Feature cards for enabled domain features
///   - Brand color palette
///
/// From here the user can navigate to LoginPage.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool isDark = false;
  String currentLang = 'en';

  @override
  void initState() {
    isDark = themeConfig.currentTheme == ThemeMode.dark;
    super.initState();
  }

  void _switchTheme(bool dark) {
    setState(() => isDark = dark);
    themeConfig.changeTheme(dark ? ThemeMode.dark : ThemeMode.light);
  }

  void _changeLanguage(String lang) {
    setState(() => currentLang = lang);
    TranslationStorage().changeLanguage(
      lang == 'en' ? Language.english.value : Language.serbian.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final tenant = TenantConfig();

    return PageFrame(
      pageBody: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeroSection(t, tenant),
            const SizedBox(height: 32),
            // Uncomment the sections only on dev mode
            // _buildSettingsSection(t),
            // const SizedBox(height: 32),
            // _buildFeaturesSection(t),
            // const SizedBox(height: 32),
            // _buildColorPaletteSection(t),
            // const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Hero: logo + app name + tagline ────────────────────────────────────────

  Widget _buildHeroSection(dynamic t, TenantConfig tenant) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(tenant.logoPath, height: 64),
          const SizedBox(height: 12),
          Text(
            tenant.appName,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: tenant.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.primaryText.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go(RouteNames.loginPage),
              style: ElevatedButton.styleFrom(
                backgroundColor: tenant.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                t.signIn,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Settings: theme and language toggles ───────────────────────────────────

  Widget _buildSettingsSection(dynamic t) {
    final features = FeatureFlags();
    final showTheme = features.themeChange;
    final showLanguage = features.language;

    if (!showTheme && !showLanguage) return const SizedBox.shrink();

    final rows = <Widget>[];

    if (showTheme) {
      rows.add(Row(
        children: [
          Icon(Icons.brightness_6_outlined, size: 20, color: context.colors.primaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.appearance,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.primaryText,
              ),
            ),
          ),
          _buildToggleChips(
            options: [(t.lightMode, !isDark), (t.darkMode, isDark)],
            onTap: (index) => _switchTheme(index == 1),
          ),
        ],
      ));
    }

    if (showTheme && showLanguage) {
      rows.add(const SizedBox(height: 16));
      rows.add(Divider(height: 1, color: context.colors.primaryText.withOpacity(0.1)));
      rows.add(const SizedBox(height: 16));
    }

    if (showLanguage) {
      rows.add(Row(
        children: [
          Icon(Icons.language, size: 20, color: context.colors.primaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.language,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.primaryText,
              ),
            ),
          ),
          _buildToggleChips(
            // SR = srpski (Serbian)
            options: [('EN', currentLang == 'en'), ('SR', currentLang == 'sr')],
            onTap: (index) => _changeLanguage(index == 0 ? 'en' : 'sr'),
          ),
        ],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(t.settings, Icons.settings_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  // ── Feature cards ──────────────────────────────────────────────────────────

  Widget _buildFeaturesSection(dynamic t) {
    final flags = FeatureFlags();

    // Build list of (icon, title, description) tuples for enabled features only
    final allFeatures = [
      if (flags.business) (Icons.business_center_outlined, t.featureBusiness, t.featureBusinessDesc),
      if (flags.poultry) (Icons.egg_outlined, t.featurePoultry, t.featurePoultryDesc),
      if (flags.reporting) (Icons.description_outlined, t.featureReporting, t.featureReportingDesc),
      if (flags.analytics) (Icons.bar_chart_outlined, t.featureAnalytics, t.featureAnalyticsDesc),
    ];

    if (allFeatures.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(t.features, Icons.grid_view_outlined),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: allFeatures.length,
          itemBuilder: (context, index) {
            final (icon, title, desc) = allFeatures[index];
            return _buildFeatureCard(icon, title, desc);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    final tenant = TenantConfig();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tenant.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: tenant.primaryColor),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.primaryText.withOpacity(0.5),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Color palette ──────────────────────────────────────────────────────────

  Widget _buildColorPaletteSection(dynamic t) {
    final tenant = TenantConfig();
    final colors = [
      (t.primary, tenant.primaryColor),
      (t.accent, tenant.accentColor),
      (t.error, tenant.errorColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(t.colorPalette, Icons.palette_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: colors.map((entry) {
              final (label, color) = entry;
              return Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.primaryText.withOpacity(0.1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    colorToHex(color),
                    style: TextStyle(
                      fontSize: 10,
                      color: context.colors.primaryText.withOpacity(0.5),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildToggleChips({
    required List<(String, bool)> options,
    required void Function(int) onTap,
  }) {
    final tenant = TenantConfig();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(options.length, (index) {
        final (label, isActive) = options[index];
        return GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? tenant.primaryColor : context.colors.primaryText.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(index == 0 ? 8 : 0),
                bottomLeft: Radius.circular(index == 0 ? 8 : 0),
                topRight: Radius.circular(index == options.length - 1 ? 8 : 0),
                bottomRight: Radius.circular(index == options.length - 1 ? 8 : 0),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : context.colors.primaryText.withOpacity(0.6),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colors.primaryText.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
      ],
    );
  }
}
