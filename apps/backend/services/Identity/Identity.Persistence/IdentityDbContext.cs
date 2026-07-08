using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Identity.Persistence;

/// <summary>
/// EF Core DbContext for the Identity microservice.
/// Entity configurations are applied automatically from all IEntityTypeConfiguration classes in this assembly.
/// </summary>
public class IdentityDbContext(DbContextOptions<IdentityDbContext> options) : DbContext(options)
{
    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<User> Users => Set<User>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Scans this assembly and applies every class that implements IEntityTypeConfiguration<T>.
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(IdentityDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
