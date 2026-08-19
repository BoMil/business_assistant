/// Navigation props for CreateEditAssetPage, passed via GoRouter's `extra`
/// instead of a path parameter. `assetId == null` means create mode.
class CreateEditAssetPageProps {
  final String? assetId;

  const CreateEditAssetPageProps({this.assetId});
}
