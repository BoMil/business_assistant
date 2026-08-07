using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Business.Persistence;

public class BusinessDbContext(DbContextOptions<BusinessDbContext> options) : DbContext(options)
{
    public DbSet<Asset> Assets => Set<Asset>();
    public DbSet<Client> Clients => Set<Client>();
    public DbSet<Transaction> Transactions => Set<Transaction>();
    public DbSet<TransactionAsset> TransactionAssets => Set<TransactionAsset>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(BusinessDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}
