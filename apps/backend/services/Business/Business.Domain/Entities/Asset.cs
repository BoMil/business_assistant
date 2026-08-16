using Shared.Domain.Common;

namespace Business.Domain.Entities;

/// <summary>
/// A generic "thing the tenant owns and stocks" — deliberately not called "Product" because
/// the same shape serves multiple tenant types without new code:
///   - Rental tenant: a rentable item (e.g. "Tiffany Stolice", Category "Furniture", RentalPrice set).
///   - Farming tenant (future): livestock, feed, or produce (e.g. "Eggs", Category "Produce", SalePrice set).
///   - Any tenant that ends up selling directly (e.g. a future shop-type tenant): SalePrice set, RentalPrice null.
/// <see cref="CategoryId"/>/<see cref="Category"/> reference an optional <see cref="Entities.Category"/> —
/// an asset doesn't have to belong to a category.
/// The "currently rented/reserved" quantity shown in the UI is NOT stored here — it's derived
/// at query time from active <see cref="Transaction"/> line items, to avoid it going stale.
/// </summary>
public class Asset : Entity<Guid>
{
    public Guid TenantId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public decimal? SalePrice { get; private set; }
    public decimal? RentalPrice { get; private set; }
    public int StockCount { get; private set; }
    public string? ImgUrl { get; private set; }
    public bool IsActive { get; private set; }
    public Guid? CategoryId { get; private set; }
    public Category? Category { get; private set; }

    private Asset() { }

    public static Asset Create(Guid tenantId, string name, Guid? categoryId, string? description, decimal? salePrice, decimal? rentalPrice, int stockCount, string? imgUrl)
    {
        return new Asset
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = name,
            CategoryId = categoryId,
            Description = description,
            SalePrice = salePrice,
            RentalPrice = rentalPrice,
            StockCount = stockCount,
            ImgUrl = imgUrl,
            IsActive = true
        };
    }

    public void Update(string name, Guid? categoryId, string? description, decimal? salePrice, decimal? rentalPrice, int stockCount, string? imgUrl)
    {
        Name = name;
        CategoryId = categoryId;
        Description = description;
        SalePrice = salePrice;
        RentalPrice = rentalPrice;
        StockCount = stockCount;
        ImgUrl = imgUrl;
    }

    public void Remove() => IsActive = false;
}
