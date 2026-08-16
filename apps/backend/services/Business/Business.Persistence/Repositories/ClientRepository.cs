using Business.Application.Repositories;
using Business.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Business.Persistence.Repositories;

internal sealed class ClientRepository(BusinessDbContext context) : IClientRepository
{
    public Task<Client?> GetByIdAsync(Guid id, Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Clients.FirstOrDefaultAsync(c => c.Id == id && c.TenantId == tenantId, cancellationToken);

    public Task<List<Client>> GetAllAsync(Guid tenantId, CancellationToken cancellationToken = default) =>
        context.Clients.Where(c => c.TenantId == tenantId).ToListAsync(cancellationToken);

    public async Task AddAsync(Client client, CancellationToken cancellationToken = default) =>
        await context.Clients.AddAsync(client, cancellationToken);

    public void Remove(Client client) => context.Clients.Remove(client);
}
