import 'package:business_assistant/core/features/events/models/responses/event_response.dart';

/// Navigation props for EventPreviewPage, passed via GoRouter's `extra`
/// instead of a path/query parameter. Carries the already-loaded event (the
/// caller — ClientEventsPage — already has it from its events list) so the
/// preview page doesn't need its own fetch/Cubit.
class EventPreviewPageProps {
  final EventResponse event;
  final String? clientName;

  const EventPreviewPageProps({required this.event, this.clientName});
}
