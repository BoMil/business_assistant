namespace Business.Application.UseCases.Common;

/// <summary>
/// Same as <see cref="AssetDto"/> plus <see cref="CurrentlyReserved"/> — the quantity tied up
/// in active Rental transactions right now. View-only, derived at query time (see
/// GetAssetByIdQueryHandler), not stored on the Asset entity, and only shown on the detail
/// view (not on the create form or the list).
/// </summary>
public record AssetDetailDto(
    Guid Id,
    string Name,
    string Category,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount,
    int CurrentlyReserved,
    string? ImgUrl);
