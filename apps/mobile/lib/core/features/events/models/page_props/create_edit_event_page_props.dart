/// Navigation props for CreateEditEventPage, passed via GoRouter's `extra`
/// instead of a path/query parameter. `eventId == null` means create mode.
/// `initialClientId` preselects the client picker when opened from a Client
/// Details page's "Add new event" button — only relevant in create mode.
class CreateEditEventPageProps {
  final String? eventId;
  final String? initialClientId;

  const CreateEditEventPageProps({this.eventId, this.initialClientId});
}
