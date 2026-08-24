/// Mirrors the backend's `PushEntityType` enum (Shared.Queues/Enums) — values
/// are parsed from the wire name the backend sends in the FCM `data` payload
/// (e.g. "Transaction"), not from Dart's own enum name.
enum PushEntityType {
  transaction,
  asset,
  client;

  static PushEntityType? fromWireName(String? value) {
    switch (value) {
      case 'Transaction':
        return PushEntityType.transaction;
      case 'Asset':
        return PushEntityType.asset;
      case 'Client':
        return PushEntityType.client;
      default:
        return null;
    }
  }
}
