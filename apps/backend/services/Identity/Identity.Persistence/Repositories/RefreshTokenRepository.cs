using Identity.Application.Repositories;
using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Identity.Persistence.Repositories;

internal sealed class RefreshTokenRepository(IdentityDbContext context) : IRefreshTokenRepository
{
    public Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default) =>
        context.RefreshTokens.FirstOrDefaultAsync(rt => rt.Token == token, cancellationToken);

    public async Task AddAsync(RefreshToken refreshToken, CancellationToken cancellationToken = default) =>
        await context.RefreshTokens.AddAsync(refreshToken, cancellationToken);
}
