using Identity.Application.Repositories;
using Identity.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Identity.Persistence.Repositories;

internal sealed class DeviceTokenRepository(IdentityDbContext context) : IDeviceTokenRepository
{
    public Task<DeviceToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default) =>
        context.DeviceTokens.FirstOrDefaultAsync(dt => dt.Token == token, cancellationToken);

    public Task<List<DeviceToken>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default) =>
        context.DeviceTokens.Where(dt => dt.UserId == userId).ToListAsync(cancellationToken);

    public async Task AddAsync(DeviceToken deviceToken, CancellationToken cancellationToken = default) =>
        await context.DeviceTokens.AddAsync(deviceToken, cancellationToken);

    public void Remove(DeviceToken deviceToken) => context.DeviceTokens.Remove(deviceToken);
}
