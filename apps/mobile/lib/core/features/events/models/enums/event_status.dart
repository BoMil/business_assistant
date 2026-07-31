/// Mirrors the Business API's TransactionStatus — derived server-side from
/// From/To against "now", never set by the client. Serialized as a string
/// (see Business.API's JsonStringEnumConverter).
enum EventStatus { pending, inProgress, finished, canceled }

EventStatus? eventStatusFromJson(String? raw) => switch (raw) {
      'Pending' => EventStatus.pending,
      'InProgress' => EventStatus.inProgress,
      'Finished' => EventStatus.finished,
      'Canceled' => EventStatus.canceled,
      _ => null,
    };
