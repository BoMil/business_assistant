/// All API endpoint paths used by Dio.
///
/// These are relative paths — the base URL always comes from
/// Environment.serverAddress (the API Gateway, see AppInterceptor().dio).
/// The leading /identity or /business segment is what the Gateway (see
/// apps/backend/gateway/Gateway.API) uses to route to the right microservice.
///
/// Identity microservice endpoints:
///   POST /identity/auth/login           → returns accessToken + refreshToken
///   POST /identity/auth/refresh-token   → exchanges refreshToken for a new accessToken
///
/// Business microservice endpoints:
///   GET/POST   /business/transactions              → list / create an event (TransactionType.Rental)
///   GET/PUT    /business/transactions/{id}          → get / update a single event
///   POST       /business/transactions/{id}/cancel   → soft-cancel an event
///   DELETE     /business/transactions/{id}          → hard-delete an event (not yet implemented server-side)
///   GET/POST   /business/assets                     → list / create an asset (product)
///   GET/PUT/DELETE /business/assets/{id}            → get / update / remove a single asset
///   GET        /business/clients                    → list clients, for the "Select client" picker
///   POST       /business/images                     → upload an image, returns its blob URL
class APIEndpoints {
  static String login = '/identity/auth/login';
  static String refreshToken = '/identity/auth/refresh-token';

  static String transactions = '/business/transactions';
  static String transactionById(String id) => '/business/transactions/$id';
  static String cancelTransaction(String id) => '/business/transactions/$id/cancel';

  static String assets = '/business/assets';
  static String assetById(String id) => '/business/assets/$id';
  static String clients = '/business/clients';
  static String images = '/business/images';
}
