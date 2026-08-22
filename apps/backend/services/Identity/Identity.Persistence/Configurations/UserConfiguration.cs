using Identity.Domain.Entities;
using Identity.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Persistence.Configurations;

internal sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasKey(u => u.Id);

        builder.Property(u => u.FirstName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(u => u.LastName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(200);

        // Email is unique globally across all tenants.
        // A user cannot register the same email under two different tenants.
        builder.HasIndex(u => u.Email).IsUnique();

        builder.Property(u => u.PhoneNumber)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(u => u.PasswordHash)
            .IsRequired()
            .HasMaxLength(500);

        // Store the enum as an int in the database (Owner=1, Admin=2, Member=3).
        builder.Property(u => u.Role)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(u => u.ImgUrl)
            .HasMaxLength(2000);

        // Relationship to Tenant is configured from TenantConfiguration.
        // HasOne is declared here for clarity but the FK constraint lives on the Tenant side.
        builder.HasMany(u => u.RefreshTokens)
            .WithOne(rt => rt.User)
            .HasForeignKey(rt => rt.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.DeviceTokens)
            .WithOne(dt => dt.User)
            .HasForeignKey(dt => dt.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
