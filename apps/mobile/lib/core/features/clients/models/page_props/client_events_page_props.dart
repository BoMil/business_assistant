/// Navigation props for ClientEventsPage, passed via GoRouter's `extra`
/// instead of a path/query parameter.
class ClientEventsPageProps {
  final String clientId;
  final String clientName;

  const ClientEventsPageProps({required this.clientId, required this.clientName});
}
