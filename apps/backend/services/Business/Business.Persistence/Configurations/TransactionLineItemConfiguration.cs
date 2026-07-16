using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Business.Persistence.Configurations;

internal sealed class TransactionLineItemConfiguration : IEntityTypeConfiguration<TransactionLineItem>
{
    public void Configure(EntityTypeBuilder<TransactionLineItem> builder)
    {
        builder.HasKey(li => li.Id);

        builder.HasIndex(li => li.AssetId);

        builder.Property(li => li.Price).HasPrecision(18, 2);
    }
}
