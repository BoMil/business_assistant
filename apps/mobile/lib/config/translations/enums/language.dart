import 'package:flutter/material.dart';

/// The supported app languages.
///
/// Each enum value holds a [Locale] that maps to an ARB file in lib/l10n/:
///   english  → lib/l10n/app_en.arb
///   serbian  → lib/l10n/app_sr.arb
/// [label]/[flagAsset] are used by LanguageSwitcher to render the picker.
///
/// Usage:
///   TranslationStorage().changeLanguage(Language.serbian.value);
enum Language {
  english(Locale('en'), 'English', 'assets/svg/flags/en.svg'),
  serbian(Locale('sr'), 'Srpski', 'assets/svg/flags/sr.svg');

  const Language(this.value, this.label, this.flagAsset);
  final Locale value;
  final String label;
  final String flagAsset;
}
