using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Business.Persistence.Configurations;

internal sealed class AssetConfiguration : IEntityTypeConfiguration<Asset>
{
    public void Configure(EntityTypeBuilder<Asset> builder)
    {
        builder.HasKey(a => a.Id);

        // Every query is scoped by TenantId — index it for fast per-tenant listing.
        builder.HasIndex(a => a.TenantId);

        builder.Property(a => a.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.HasOne(a => a.Category)
            .WithMany()
            .HasForeignKey(a => a.CategoryId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.Property(a => a.Description)
            .HasMaxLength(1000);

        builder.Property(a => a.ImgUrl)
            .HasMaxLength(2000);

        builder.Property(a => a.SalePrice).HasPrecision(18, 2);
        builder.Property(a => a.RentalPrice).HasPrecision(18, 2);
    }
}
