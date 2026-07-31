// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Your complete business operations platform';

  @override
  String get signIn => 'Sign In';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get features => 'Features';

  @override
  String get featureBusiness => 'Business';

  @override
  String get featureBusinessDesc => 'Manage products, employees and expenses';

  @override
  String get featurePoultry => 'Poultry';

  @override
  String get featurePoultryDesc => 'Track flocks, feed, mortality and health';

  @override
  String get featureReporting => 'Reporting';

  @override
  String get featureReportingDesc =>
      'Export and schedule PDF and Excel reports';

  @override
  String get featureAnalytics => 'Analytics';

  @override
  String get featureAnalyticsDesc => 'Charts and KPI summaries at a glance';

  @override
  String get colorPalette => 'Brand Colors';

  @override
  String get primary => 'Primary';

  @override
  String get accent => 'Accent';

  @override
  String get error => 'Error';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get fieldIsRequired => 'This field is required';

  @override
  String get fieldDoesntPassRegularExpressionValidation =>
      'This field is invalid';

  @override
  String get noItemsAvailable => 'No items available';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get genericErrorMessage => 'Something went wrong. Please try again.';

  @override
  String get eventStatusPending => 'Pending';

  @override
  String get eventStatusInProgress => 'In Progress';

  @override
  String get eventStatusFinished => 'Finished';

  @override
  String get eventStatusCanceled => 'Canceled';

  @override
  String get eventsSearchHint => 'Search events...';

  @override
  String get eventsEmptyStateText => 'No events yet';

  @override
  String get eventDetailsTitle => 'Event Details';

  @override
  String get eventTitleLabel => 'Title';

  @override
  String get eventDescriptionLabel => 'Description';

  @override
  String get eventFromLabel => 'From';

  @override
  String get eventToLabel => 'To';

  @override
  String get eventLocationLabel => 'Location';

  @override
  String get eventSelectClientLabel => 'Select client (optional)';

  @override
  String get eventProductsLabel => 'Products';

  @override
  String get addProductButton => 'Add product';

  @override
  String get eventSelectDatesFirstHint => 'Select From and To dates first';

  @override
  String get selectProductTitle => 'Select Product';

  @override
  String get selectClientTitle => 'Select Client';

  @override
  String get cancelEventButton => 'Cancel Event';

  @override
  String get confirmCancelEvent =>
      'Are you sure you want to cancel this event?';

  @override
  String get deleteEventButton => 'Delete';

  @override
  String get confirmDeleteEvent =>
      'Are you sure you want to delete this event? This cannot be undone.';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get createEventButton => 'Create Event';

  @override
  String get eventSavedToast => 'Event saved';

  @override
  String get eventCancelledToast => 'Event canceled';

  @override
  String get eventDeletedToast => 'Event deleted';
}
