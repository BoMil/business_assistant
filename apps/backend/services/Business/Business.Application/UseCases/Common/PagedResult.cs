namespace Business.Application.UseCases.Common;

/// <summary>
/// Generic paged list wrapper — mirrors the mobile client's BaseMultiPageResponse&lt;T&gt;
/// (apps/mobile/lib/core/shared/models/base_multi_page_response.dart) field-for-field so
/// results serialize into the exact shape the Flutter pagination cubit expects.
/// </summary>
public record PagedResult<T>(
    int PageIndex,
    int Count,
    int TotalPages,
    List<T> Items,
    bool HasPreviousPage,
    bool HasNextPage)
{
    public static PagedResult<T> Create(List<T> items, int pageIndex, int pageSize, int totalCount)
    {
        var totalPages = pageSize > 0 ? (int)Math.Ceiling(totalCount / (double)pageSize) : 0;
        return new PagedResult<T>(
            PageIndex: pageIndex,
            Count: totalCount,
            TotalPages: totalPages,
            Items: items,
            HasPreviousPage: pageIndex > 1,
            HasNextPage: pageIndex < totalPages);
    }
}
