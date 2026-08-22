import 'package:firebase_core/firebase_core.dart';

/// Singleton exposing the current tenant's Firebase project config — each
/// tenant has its own Firebase project, baked in at build time the same way
/// as every other per-tenant value (see TenantConfig). No native
/// google-services.json is used: FirebaseOptions is built directly here and
/// passed to Firebase.initializeApp(), which needs nothing else on Android.
///
/// Android only for now — no iOS fields.
class FirebaseConfig {
  static final FirebaseConfig _instance = FirebaseConfig._internal();
  factory FirebaseConfig() => _instance;
  FirebaseConfig._internal();

  final String apiKey = const String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: '');
  final String appId = const String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: '');
  final String messagingSenderId = const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  final String projectId = const String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
  final String storageBucket = const String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');

  /// A tenant with no Firebase project configured yet has all-empty values —
  /// Firebase is simply never initialized for that build.
  bool get isConfigured => apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty;

  FirebaseOptions get currentPlatform => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );
}
