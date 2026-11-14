import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/routes/route_names.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
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
  @override
  Widget build(BuildContext context) {
    final t = TranslationStorage.translation;
    final tenant = TenantConfig();

    return PageFrame(
      isHeaderVisible: false,
      pageBody: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
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
      pageBottomBar: _buildSignInButton(t),
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
              color: context.colors.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.primaryText.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign In button ─────────────────────────────────────────────────────────

  Widget _buildSignInButton(dynamic t) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          ThemeConstants.pagePadding,
          12,
          ThemeConstants.pagePadding,
          16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => context.go(RouteNames.loginPage),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.brandPrimary,
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
      ),
    );
  }
}
