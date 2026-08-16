using Business.Domain.Entities;

namespace Business.Application.Repositories;

public interface IClientRepository
{
    Task<Client?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default);
    Task<List<Client>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default);
    Task AddAsync(Client client, CancellationToken cancellationToken = default);
    void Remove(Client client);
}
