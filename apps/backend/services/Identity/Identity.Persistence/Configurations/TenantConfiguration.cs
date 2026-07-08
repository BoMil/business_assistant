using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Persistence.Configurations;

internal sealed class TenantConfiguration : IEntityTypeConfiguration<Tenant>
{
    public void Configure(EntityTypeBuilder<Tenant> builder)
    {
        builder.HasKey(t => t.Id);

        builder.Property(t => t.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(t => t.Slug)
            .IsRequired()
            .HasMaxLength(100);

        // Slug must be unique — used for tenant lookup and white-label URL routing.
        builder.HasIndex(t => t.Slug).IsUnique();

        builder.Property(t => t.LogoUrl)
            .HasMaxLength(500);

        builder.Property(t => t.PrimaryColor)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(t => t.SecondaryColor)
            .IsRequired()
            .HasMaxLength(20);

        // FeatureFlags is stored as a JSON column in a single SQL column ("FeatureFlags").
        // EF Core 8 handles serialization/deserialization automatically.
        // This avoids a separate table for a simple per-tenant config object.
        builder.OwnsOne(t => t.FeatureFlags, ff =>
        {
            ff.ToJson();
        });

        builder.HasMany(t => t.Users)
            .WithOne(u => u.Tenant)
            .HasForeignKey(u => u.TenantId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
