/// Navigation props for CreateEditClientPage, passed via GoRouter's `extra`
/// instead of a path/query parameter. `clientId == null` means create mode.
class CreateEditClientPageProps {
  final String? clientId;

  const CreateEditClientPageProps({this.clientId});
}
