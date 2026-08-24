/// Mirrors the backend's `PushAction` enum (Shared.Queues/Enums) — values are
/// parsed from the wire name the backend sends in the FCM `data` payload
/// (e.g. "Created"), not from Dart's own enum name.
enum PushAction {
  created,
  updated,
  deleted;

  static PushAction? fromWireName(String? value) {
    switch (value) {
      case 'Created':
        return PushAction.created;
      case 'Updated':
        return PushAction.updated;
      case 'Deleted':
        return PushAction.deleted;
      default:
        return null;
    }
  }
}
