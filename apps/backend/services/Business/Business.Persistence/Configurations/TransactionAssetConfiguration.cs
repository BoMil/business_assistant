using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Business.Persistence.Configurations;

internal sealed class TransactionAssetConfiguration : IEntityTypeConfiguration<TransactionAsset>
{
    public void Configure(EntityTypeBuilder<TransactionAsset> builder)
    {
        builder.HasKey(asset => asset.Id);

        builder.HasIndex(asset => asset.AssetId);

        builder.Property(asset => asset.Price).HasPrecision(18, 2);
    }
}
