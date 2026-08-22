import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:toastification/toastification.dart';
import 'package:business_assistant/config/environment/environment.dart';
import 'package:business_assistant/config/firebase/firebase_config.dart';
import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';
import 'package:business_assistant/config/routes/router_config.dart';
import 'package:business_assistant/config/routes/routes.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/authentication/cubits/user_info/user_info_cubit.dart';
import 'package:business_assistant/core/features/bottom_navigation/cubits/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:business_assistant/core/features/push_notifications/services/local_notifications_service.dart';
import 'package:business_assistant/core/features/push_notifications/services/push_notification_service.dart';
import 'package:business_assistant/core/features/tenant/cubits/tenant_config/tenant_config_cubit.dart';
import 'package:business_assistant/core/utils/api/app_interceptor.dart';
import 'package:business_assistant/l10n/app_localizations.dart';
import 'package:business_assistant/theme/theme_config.dart';
import 'package:business_assistant/theme/themes.dart';

/// Entry point of the Business Assistant mobile app.
///
/// Startup sequence:
///   1. Suppress debug prints in non-DEV environments.
///   2. Initialize Firebase, if this tenant has a project configured.
///   3. Initialize the Dio interceptor (token injection + 401 refresh).
///   4. Run MyApp.
void main() async {
  // Disable all debugPrint() calls in release mode and non-DEV environments
  // so no sensitive data appears in device logs on staging/production.
  if (kReleaseMode || Environment.environment != 'DEV') {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  WidgetsFlutterBinding.ensureInitialized();

  if (FirebaseConfig().isConfigured) {
    await Firebase.initializeApp(options: FirebaseConfig().currentPlatform);
    await LocalNotificationsService().init();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => PushNotificationService().registerCurrentToken());
    // FCM only auto-shows a notification when the app is backgrounded/killed —
    // in the foreground we have to display it ourselves.
    FirebaseMessaging.onMessage.listen(
      (message) => LocalNotificationsService().showNotification(message.notification?.title, message.notification?.body),
    );
  }

  // Set up the singleton Dio instance with the auth interceptor before any
  // repository can make an HTTP call.
  AppInterceptor().initializeInterceptor();

  runApp(const MyApp());
}

/// Must be a top-level function — Firebase's own requirement for background
/// message handling. No-op body: v1 only needs the OS to show the
/// notification, which happens automatically without any handling here.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// AuthCubit is created here so it lives for the lifetime of the app.
  /// It is shared with RouterState (for GoRouter's redirect) and provided
  /// to the widget tree via MultiBlocProvider.
  AuthCubit authCubit = AuthCubit(secureStorage: const FlutterSecureStorage());

  @override
  void initState() {
    // Give GoRouter access to authCubit before the first build
    RouterState().authCubit = authCubit;

    // Load translations for the default locale (English) so
    // TranslationStorage.translation is usable before the first frame
    TranslationStorage().initTranslation();
    TranslationStorage().onLanguageChanged = _onLanguageChanged;

    // Register theme change callback — setState() causes MaterialApp.router
    // to re-read ThemeConfig().currentTheme and apply the new theme
    ThemeConfig().onThemeChanged = _onThemeChange;
    _initializeTheme();

    super.initState();
  }

  /// Reads the persisted theme from secure storage and applies it.
  Future<void> _initializeTheme() async {
    ThemeMode themeMode = await ThemeConfig().initThemeConfig();
    ThemeConfig().changeTheme(themeMode);
  }

  @override
  void dispose() {
    // Close the stream to avoid memory leaks
    RouterState().authCubit.close();
    super.dispose();
  }

  void _onThemeChange(ThemeMode themeMode) => setState(() {});

  void _onLanguageChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Reset navigator keys and recalculate initialRoute on every rebuild.
    // This is safe because GoRouter caches its own state internally.
    RouterState().initializeRouteState();

    return MultiBlocProvider(
      providers: [
        // AuthCubit is global — GoRouter's redirect and all screens can read it
        BlocProvider(create: (context) => RouterState().authCubit..initAuthState()),
        // Global so any widget can request a bottom nav tab switch — see
        // BottomNavigationCubit for why BottomNavigationFrame alone isn't enough.
        BlocProvider(create: (context) => BottomNavigationCubit(tabs: visibleBottomNavTabs())),
        // Global so any widget can read the tenant's currency/symbol for display.
        BlocProvider(create: (context) => TenantConfigCubit()),
        // Global so any widget can read the logged-in user's profile/role —
        // populated/cleared from the BlocListener below, not by AuthCubit itself.
        BlocProvider(create: (context) => UserInfoCubit()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<UserInfoCubit>().loadUserInfo();
            if (FirebaseConfig().isConfigured) PushNotificationService().registerCurrentToken();
          }
          if (state is Unauthenticated) {
            // Next login should start on the first tab, not wherever the user left off.
            context.read<BottomNavigationCubit>().resetCurrentIndex();
            context.read<UserInfoCubit>().clear();
          }
        },
        // ToastificationWrapper must wrap MaterialApp so toastification.show()
        // works from anywhere in the app without a BuildContext
        child: ToastificationWrapper(
          child: MaterialApp.router(
            theme: Themes.light,
            darkTheme: Themes.dark,
            themeMode: ThemeConfig().currentTheme,
            locale: TranslationStorage().selectedLanguage,
            routerDelegate: Routes().goRouterInstance.routerDelegate,
            routeInformationProvider: Routes().goRouterInstance.routeInformationProvider,
            routeInformationParser: Routes().goRouterInstance.routeInformationParser,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
  }
}
