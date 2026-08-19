/// Query params for GET /assets/paged — mirrors the Business API's
/// page/pageSize/search parameters (see GetAssetsPaged.Handle).
class AssetsRequest {
  int page;
  int pageSize;
  String? searchQuery;

  AssetsRequest({required this.page, required this.pageSize, this.searchQuery});

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'pageSize': pageSize,
        if (searchQuery != null && searchQuery!.isNotEmpty) 'search': searchQuery,
      };
}
