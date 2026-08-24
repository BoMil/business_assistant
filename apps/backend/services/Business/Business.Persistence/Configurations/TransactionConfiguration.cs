using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Business.Persistence.Configurations;

internal sealed class TransactionConfiguration : IEntityTypeConfiguration<Transaction>
{
    public void Configure(EntityTypeBuilder<Transaction> builder)
    {
        builder.HasKey(t => t.Id);

        builder.HasIndex(t => t.TenantId);
        // Speeds up the overlap-availability query (filters by ClientId and by From/To range).
        builder.HasIndex(t => t.ClientId);

        builder.Property(t => t.Type)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(t => t.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(t => t.Description)
            .HasMaxLength(1000);

        builder.OwnsOne(t => t.Location, loc =>
        {
            loc.Property(l => l.Address).HasColumnName("LocationAddress").HasMaxLength(500);
            loc.Property(l => l.Latitude).HasColumnName("LocationLatitude");
            loc.Property(l => l.Longitude).HasColumnName("LocationLongitude");
        });

        builder.Metadata.FindNavigation(nameof(Transaction.Assets))!
            .SetPropertyAccessMode(PropertyAccessMode.Field);

        builder.HasMany(t => t.Assets)
            .WithOne()
            .HasForeignKey(asset => asset.TransactionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Metadata.FindNavigation(nameof(Transaction.Costs))!
            .SetPropertyAccessMode(PropertyAccessMode.Field);

        builder.HasMany(t => t.Costs)
            .WithOne()
            .HasForeignKey(cost => cost.TransactionId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
