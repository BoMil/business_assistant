using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Identity.Persistence.Configurations;

internal sealed class DeviceTokenConfiguration : IEntityTypeConfiguration<DeviceToken>
{
    public void Configure(EntityTypeBuilder<DeviceToken> builder)
    {
        builder.HasKey(dt => dt.Id);

        // FCM tokens run longer than the 256 used for RefreshToken — give them headroom.
        builder.Property(dt => dt.Token)
            .IsRequired()
            .HasMaxLength(500);

        // Unique so re-registering the same token is a safe upsert, not a duplicate row.
        builder.HasIndex(dt => dt.Token).IsUnique();
    }
}
