namespace Business.Application.UseCases.Common;

public record AssetDto(
    Guid Id,
    string Name,
    Guid? CategoryId,
    string? CategoryName,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount,
    string? ImgUrl);
