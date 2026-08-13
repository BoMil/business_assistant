namespace Business.Presentation.Endpoints.Assets;

/// <summary>JSON body for POST /assets.</summary>
public record CreateAssetRequest(
    string Name,
    string Category,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount,
    string? ImgUrl);
