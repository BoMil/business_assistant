using Identity.Domain.Entities;

namespace Identity.Application.Repositories;

public interface IDeviceTokenRepository
{
    Task<DeviceToken?> GetByTokenAsync(string token, CancellationToken cancellationToken = default);
    Task<List<DeviceToken>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task AddAsync(DeviceToken deviceToken, CancellationToken cancellationToken = default);
    void Remove(DeviceToken deviceToken);
}
