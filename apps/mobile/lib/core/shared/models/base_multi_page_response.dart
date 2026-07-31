class BaseMultiPageResponse<T> {
  int pageIndex;
  int count;
  int totalPages;
  List<T> items;
  bool hasPreviousPage;
  bool hasNextPage;

  BaseMultiPageResponse({
    required this.pageIndex,
    required this.count,
    required this.totalPages,
    required this.items,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  BaseMultiPageResponse.empty()
      : pageIndex = 0,
        totalPages = 0,
        count = 0,
        hasNextPage = false,
        hasPreviousPage = false,
        items = [];
}
