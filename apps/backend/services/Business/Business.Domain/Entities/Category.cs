using Shared.Domain.Common;
namespace Business.Domain.Entities;

public class Category : Entity<Guid>
{
    public Guid TenantId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string? ImgUrl { get; private set; }

    private Category() { }

    public static Category Create(Guid tenantId, string name, string? imgUrl)
    {
        return new Category
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = name,
            ImgUrl = imgUrl
        };
    }

    public void Update(string name, string? imgUrl)
    {
        Name = name;
        ImgUrl = imgUrl;
    }
}
