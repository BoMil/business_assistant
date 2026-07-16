namespace Business.Application.UseCases.Common;

public record AssetDto(
    Guid Id,
    string Name,
    string Category,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount);
