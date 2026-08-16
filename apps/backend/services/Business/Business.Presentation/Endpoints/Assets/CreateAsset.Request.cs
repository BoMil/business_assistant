namespace Business.Presentation.Endpoints.Assets;

/// <summary>JSON body for POST /assets.</summary>
public record CreateAssetRequest(
    string Name,
    Guid? CategoryId,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount,
    string? ImgUrl);
