using Business.Application.Repositories;

namespace Business.Persistence.Repositories;

internal sealed class UnitOfWorkBusiness : IUnitOfWorkBusiness
{
    private readonly BusinessDbContext _context;
    private IAssetRepository? _assetRepository;
    private IClientRepository? _clientRepository;
    private ITransactionRepository? _transactionRepository;

    public UnitOfWorkBusiness(BusinessDbContext context)
    {
        _context = context;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _context.SaveChangesAsync(cancellationToken);

    public IAssetRepository Assets => _assetRepository ??= new AssetRepository(_context);
    public IClientRepository Clients => _clientRepository ??= new ClientRepository(_context);
    public ITransactionRepository Transactions => _transactionRepository ??= new TransactionRepository(_context);
}
