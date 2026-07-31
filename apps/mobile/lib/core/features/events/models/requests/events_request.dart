/// Query params for GET /transactions — mirrors the Business API's
/// page/pageSize/search parameters (see GetTransactions.Handle).
class EventsRequest {
  int page;
  int pageSize;
  String? searchQuery;

  EventsRequest({required this.page, required this.pageSize, this.searchQuery});

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'pageSize': pageSize,
        if (searchQuery != null && searchQuery!.isNotEmpty) 'search': searchQuery,
      };
}
