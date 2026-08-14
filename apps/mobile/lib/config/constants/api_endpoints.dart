/// All API endpoint paths used by Dio.
///
/// These are relative paths — the base URL comes from Environment.serverAddress
/// (Identity) or Environment.businessServerAddress (Business), depending on
/// which Dio instance (AppInterceptor().dio vs .businessDio) issues the call.
///
/// Identity microservice endpoints:
///   POST /auth/login           → returns accessToken + refreshToken
///   POST /auth/refresh-token   → exchanges refreshToken for a new accessToken
///
/// Business microservice endpoints:
///   GET/POST   /transactions              → list / create an event (TransactionType.Rental)
///   GET/PUT    /transactions/{id}          → get / update a single event
///   POST       /transactions/{id}/cancel   → soft-cancel an event
///   DELETE     /transactions/{id}          → hard-delete an event (not yet implemented server-side)
///   GET/POST   /assets                     → list / create an asset (product)
///   GET/PUT/DELETE /assets/{id}            → get / update / remove a single asset
///   GET        /clients                    → list clients, for the "Select client" picker
///   POST       /images                     → upload an image, returns its blob URL
class APIEndpoints {
  static String login = '/auth/login';
  static String refreshToken = '/auth/refresh-token';

  static String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';
  static String cancelTransaction(String id) => '/transactions/$id/cancel';

  static String assets = '/assets';
  static String assetById(String id) => '/assets/$id';
  static String clients = '/clients';
  static String images = '/images';
}
