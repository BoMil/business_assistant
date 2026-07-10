import 'package:flutter/material.dart';

/// The supported app languages.
///
/// Each enum value holds a [Locale] that maps to an ARB file in lib/l10n/:
///   english  → lib/l10n/app_en.arb
///   serbian  → lib/l10n/app_sr.arb
///
/// Usage:
///   TranslationStorage().changeLanguage(Language.serbian.value);
enum Language {
  english(Locale('en')),
  serbian(Locale('sr'));

  const Language(this.value);
  final Locale value;
}
