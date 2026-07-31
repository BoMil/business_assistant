import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
  ];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your complete business operations platform'**
  String get appTagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @featureBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get featureBusiness;

  /// No description provided for @featureBusinessDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage products, employees and expenses'**
  String get featureBusinessDesc;

  /// No description provided for @featurePoultry.
  ///
  /// In en, this message translates to:
  /// **'Poultry'**
  String get featurePoultry;

  /// No description provided for @featurePoultryDesc.
  ///
  /// In en, this message translates to:
  /// **'Track flocks, feed, mortality and health'**
  String get featurePoultryDesc;

  /// No description provided for @featureReporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get featureReporting;

  /// No description provided for @featureReportingDesc.
  ///
  /// In en, this message translates to:
  /// **'Export and schedule PDF and Excel reports'**
  String get featureReportingDesc;

  /// No description provided for @featureAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get featureAnalytics;

  /// No description provided for @featureAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Charts and KPI summaries at a glance'**
  String get featureAnalyticsDesc;

  /// No description provided for @colorPalette.
  ///
  /// In en, this message translates to:
  /// **'Brand Colors'**
  String get colorPalette;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @accent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get accent;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @fieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldIsRequired;

  /// No description provided for @fieldDoesntPassRegularExpressionValidation.
  ///
  /// In en, this message translates to:
  /// **'This field is invalid'**
  String get fieldDoesntPassRegularExpressionValidation;

  /// No description provided for @noItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get noItemsAvailable;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @genericErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericErrorMessage;

  /// No description provided for @eventStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get eventStatusPending;

  /// No description provided for @eventStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get eventStatusInProgress;

  /// No description provided for @eventStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get eventStatusFinished;

  /// No description provided for @eventStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get eventStatusCanceled;

  /// No description provided for @eventsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search events...'**
  String get eventsSearchHint;

  /// No description provided for @eventsEmptyStateText.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get eventsEmptyStateText;

  /// No description provided for @eventDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetailsTitle;

  /// No description provided for @eventTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitleLabel;

  /// No description provided for @eventDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescriptionLabel;

  /// No description provided for @eventFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get eventFromLabel;

  /// No description provided for @eventToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get eventToLabel;

  /// No description provided for @eventLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get eventLocationLabel;

  /// No description provided for @eventSelectClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Select client (optional)'**
  String get eventSelectClientLabel;

  /// No description provided for @eventProductsLabel.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get eventProductsLabel;

  /// No description provided for @addProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductButton;

  /// No description provided for @eventSelectDatesFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Select From and To dates first'**
  String get eventSelectDatesFirstHint;

  /// No description provided for @selectProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProductTitle;

  /// No description provided for @selectClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClientTitle;

  /// No description provided for @cancelEventButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel Event'**
  String get cancelEventButton;

  /// No description provided for @confirmCancelEvent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this event?'**
  String get confirmCancelEvent;

  /// No description provided for @deleteEventButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteEventButton;

  /// No description provided for @confirmDeleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this event? This cannot be undone.'**
  String get confirmDeleteEvent;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @createEventButton.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEventButton;

  /// No description provided for @eventSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Event saved'**
  String get eventSavedToast;

  /// No description provided for @eventCancelledToast.
  ///
  /// In en, this message translates to:
  /// **'Event canceled'**
  String get eventCancelledToast;

  /// No description provided for @eventDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Event deleted'**
  String get eventDeletedToast;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
