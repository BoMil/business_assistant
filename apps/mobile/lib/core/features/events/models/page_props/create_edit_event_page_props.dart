import 'package:business_assistant/core/features/events/models/responses/event_response.dart';

/// Navigation props for CreateEditEventPage, passed via GoRouter's `extra`
/// instead of a path/query parameter. `eventId == null` means create mode.
/// `initialClientId` preselects the client picker when opened from a Client
/// Details page's "Add new event" button — only relevant in create mode.
/// `event`, when the caller already has it (e.g. EventPreviewPage), lets edit
/// mode populate the form from it directly instead of re-fetching by id.
class CreateEditEventPageProps {
  final String? eventId;
  final String? initialClientId;
  final EventResponse? event;

  const CreateEditEventPageProps({this.eventId, this.initialClientId, this.event});
}
