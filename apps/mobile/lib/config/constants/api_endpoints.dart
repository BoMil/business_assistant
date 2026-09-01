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
///   GET  /identity/users/me             → the logged-in user's profile (incl. imgUrl)
///   PUT  /identity/users/me/image       → set/clear the logged-in user's profile picture URL
///   POST /identity/images               → upload an image, returns its blob URL
///   POST   /identity/users/me/device-tokens → register this device's FCM token
///   DELETE /identity/users/me/device-tokens → remove this device's FCM token
///
/// Business microservice endpoints:
///   GET/POST   /business/transactions              → list / create an event (TransactionType.Rental)
///   GET        /business/transactions/by-date-range → unpaginated list of events overlapping [from,to] (calendar view)
///   GET/PUT    /business/transactions/{id}          → get / update a single event
///   POST       /business/transactions/{id}/cancel   → soft-cancel an event
///   DELETE     /business/transactions/{id}          → hard-delete an event (not yet implemented server-side)
///   GET/POST   /business/assets                     → list (unpaginated) / create an asset (product)
///   GET        /business/assets/paged                → paginated, server-searched list of assets
///   GET/PUT/DELETE /business/assets/{id}            → get / update / remove a single asset
///   GET/POST   /business/categories                 → list / create an asset category
///   GET/PUT/DELETE /business/categories/{id}        → get / update / remove a single category
///   GET/POST   /business/clients                    → list / create a client
///   GET/PUT/DELETE /business/clients/{id}           → get / update / remove a single client
///   GET        /business/clients/{id}/transactions  → list a client's events
///   POST       /business/images                     → upload an image, returns its blob URL
class APIEndpoints {
  static String login = '/identity/auth/login';
  static String refreshToken = '/identity/auth/refresh-token';
  static String currentUser = '/identity/users/me';
  static String updateUserImage = '/identity/users/me/image';
  static String identityImages = '/identity/images';
  static String deviceTokens = '/identity/users/me/device-tokens';

  static String transactions = '/business/transactions';
  static String transactionsByDateRange = '/business/transactions/by-date-range';
  static String transactionById(String id) => '/business/transactions/$id';
  static String cancelTransaction(String id) => '/business/transactions/$id/cancel';

  static String assets = '/business/assets';
  static String assetsPaged = '/business/assets/paged';
  static String assetById(String id) => '/business/assets/$id';
  static String categories = '/business/categories';
  static String categoryById(String id) => '/business/categories/$id';
  static String clients = '/business/clients';
  static String clientById(String id) => '/business/clients/$id';
  static String clientTransactions(String id) => '/business/clients/$id/transactions';
  static String images = '/business/images';
}
