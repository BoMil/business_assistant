using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Business.Persistence.Configurations;

internal sealed class ClientConfiguration : IEntityTypeConfiguration<Client>
{
    public void Configure(EntityTypeBuilder<Client> builder)
    {
        builder.HasKey(c => c.Id);

        builder.HasIndex(c => c.TenantId);

        builder.Property(c => c.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.PhoneNumber)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(c => c.Email)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.Description)
            .HasMaxLength(1000);

        // Plain owned columns (not JSON) — Address/Latitude/Longitude are simple and worth
        // keeping queryable/indexable individually, unlike FeatureFlags' bag-of-booleans shape.
        builder.OwnsOne(c => c.Location, loc =>
        {
            loc.Property(l => l.Address).HasColumnName("LocationAddress").HasMaxLength(500);
            loc.Property(l => l.Latitude).HasColumnName("LocationLatitude");
            loc.Property(l => l.Longitude).HasColumnName("LocationLongitude");
        });
    }
}
