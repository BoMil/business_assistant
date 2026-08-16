using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

// Notes:
// Category.cs opisuje šta kategorija jeste (poslovna pravila), CategoryConfiguration.cs opisuje kako se to čuva u SQL Server tabeli (kolone, indeksi, FK). 
// Odvojeno namerno, da promena baze (npr. promena max length-a) nikad ne dira Domain kod.
namespace Business.Persistence.Configurations;

internal sealed class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.HasKey(c => c.Id);

        builder.HasIndex(c => c.TenantId);

        builder.Property(c => c.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(c => c.ImgUrl)
            .HasMaxLength(2000);

        builder.HasIndex(c => new { c.TenantId, c.Name }).IsUnique();
    }
}