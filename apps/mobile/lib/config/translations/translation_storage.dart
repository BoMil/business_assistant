import 'package:flutter/material.dart';
import 'package:business_assistant/l10n/app_localizations.dart';

typedef LanguageChangeCallback = void Function();

/// Singleton that holds the current AppLocalizations object and language.
///
/// Problem it solves:
///   AppLocalizations.of(context) requires a BuildContext — you can't use it
///   in Cubits, validators, or service classes that have no context.
///   This singleton loads translations eagerly and exposes them via a static getter
///   so any class in the app can call TranslationStorage.translation.someKey.
///
/// Usage:
///   // Access translations without context
///   final msg = TranslationStorage.translation.loginError;
///
///   // Change language (triggers a UI rebuild via onLanguageChanged callback)
///   TranslationStorage().changeLanguage(Language.serbian.value);
class TranslationStorage {
  static final TranslationStorage _singleton = TranslationStorage._internal();

  factory TranslationStorage() => _singleton;
  TranslationStorage._internal();

  late AppLocalizations _translation;

  /// The locale currently displayed in the app. Starts with English.
  Locale selectedLanguage = const Locale('sr');

  /// Context-free access to the current translations.
  static AppLocalizations get translation => _singleton._translation;

  /// Called by main.dart after a language change so the widget tree rebuilds.
  LanguageChangeCallback? onLanguageChanged;

  /// Load translations for [selectedLanguage] on app startup.
  /// Must be called in initState() before any translation is accessed.
  void initTranslation() async {
    _translation = await AppLocalizations.delegate.load(selectedLanguage);
  }

  /// Switch the app language and notify the widget tree to rebuild.
  void changeLanguage(Locale locale) async {
    if (!_checkIfLanguageIsSupported(locale)) return;
    selectedLanguage = locale;
    _translation = await AppLocalizations.delegate.load(selectedLanguage);
    _singleton.onLanguageChanged?.call();
  }

  bool _checkIfLanguageIsSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }
}
