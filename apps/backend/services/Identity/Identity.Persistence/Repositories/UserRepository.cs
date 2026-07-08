using Identity.Application.Repositories;
using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Identity.Persistence.Repositories;

internal sealed class UserRepository(IdentityDbContext context) : IUserRepository
{
    public Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default) =>
        // Include Tenant so that handlers can access branding and feature flags without a second query.
        context.Users
            .Include(u => u.Tenant)
            .FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default) =>
        context.Users
            .Include(u => u.Tenant)
            .FirstOrDefaultAsync(u => u.Email == email.ToLowerInvariant(), cancellationToken);

    public Task<bool> ExistsByEmailAsync(string email, CancellationToken cancellationToken = default) =>
        context.Users.AnyAsync(u => u.Email == email.ToLowerInvariant(), cancellationToken);

    public async Task AddAsync(User user, CancellationToken cancellationToken = default) =>
        await context.Users.AddAsync(user, cancellationToken);
}
