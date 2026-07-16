namespace Business.Presentation.Endpoints.Assets;

/// <summary>JSON body for PUT /assets/{id}.</summary>
public record UpdateAssetRequest(
    string Name,
    string Category,
    string? Description,
    decimal? SalePrice,
    decimal? RentalPrice,
    int StockCount);
