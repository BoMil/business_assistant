using Identity.Application.Repositories;

namespace Identity.Persistence.Repositories;

internal sealed class UnitOfWorkIdentity : IUnitOfWorkIdentity
{
    private readonly IdentityDbContext _context;
    private IUserRepository? _userRepository;
    private ITenantRepository? _tenantRepository;
    private IRefreshTokenRepository? _refreshTokenRepository;

    public UnitOfWorkIdentity(IdentityDbContext context)
    {
        _context = context;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _context.SaveChangesAsync(cancellationToken);

    public IUserRepository Users => _userRepository ??= new UserRepository(_context);
    public ITenantRepository Tenants => _tenantRepository ??= new TenantRepository(_context);
    public IRefreshTokenRepository RefreshTokens => _refreshTokenRepository ??= new RefreshTokenRepository(_context);
}
