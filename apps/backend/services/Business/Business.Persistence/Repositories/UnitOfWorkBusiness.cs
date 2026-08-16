using Business.Application.Repositories;

namespace Business.Persistence.Repositories;

internal sealed class UnitOfWorkBusiness : IUnitOfWorkBusiness
{
    // Shared by every repository below, so their changes all land in one SaveChangesAsync/transaction.
    private readonly BusinessDbContext _context;
    // Lazily created — a repository is only instantiated the first time a handler touches it.
    private IAssetRepository? _assetRepository;
    private IClientRepository? _clientRepository;
    private ITransactionRepository? _transactionRepository;
    private ICategoryRepository? _categoryRepository;

    public UnitOfWorkBusiness(BusinessDbContext context)
    {
        _context = context;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _context.SaveChangesAsync(cancellationToken);

    public IAssetRepository Assets => _assetRepository ??= new AssetRepository(_context);
    public IClientRepository Clients => _clientRepository ??= new ClientRepository(_context);
    public ITransactionRepository Transactions => _transactionRepository ??= new TransactionRepository(_context);
    public ICategoryRepository Categories => _categoryRepository ??= new CategoryRepository(_context);
}
