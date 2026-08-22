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

        builder.Property(t => t.AccentColor)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(t => t.ErrorColor)
            .IsRequired()
            .HasMaxLength(20);

        // Store the enum as an int in the database (Rental=1, Farming=2).
        builder.Property(t => t.Type)
            .HasConversion<int>()
            .IsRequired();

        // ISO 4217 code (e.g. "EUR", "RSD") — display-only, no conversion logic.
        builder.Property(t => t.Currency)
            .IsRequired()
            .HasMaxLength(3);

        // FeatureFlags/Modules are each stored as a JSON column in a single SQL column.
        // EF Core 8 handles serialization/deserialization automatically.
        // This avoids a separate table for simple per-tenant config objects.
        builder.OwnsOne(t => t.FeatureFlags, ff =>
        {
            ff.ToJson();
        });

        builder.OwnsOne(t => t.Modules, m =>
        {
            m.ToJson();
        });

        builder.OwnsOne(t => t.FirebaseConfig, fc =>
        {
            fc.ToJson();
        });

        builder.HasMany(t => t.Users)
            .WithOne(u => u.Tenant)
            .HasForeignKey(u => u.TenantId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
