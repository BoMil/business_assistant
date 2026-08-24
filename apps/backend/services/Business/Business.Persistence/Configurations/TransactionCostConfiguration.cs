using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Business.Persistence.Configurations;

internal sealed class TransactionCostConfiguration : IEntityTypeConfiguration<TransactionCost>
{
    public void Configure(EntityTypeBuilder<TransactionCost> builder)
    {
        builder.HasKey(c => c.Id);

        builder.Property(c => c.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.Cost).HasPrecision(18, 2);
    }
}
