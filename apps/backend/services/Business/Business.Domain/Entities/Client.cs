using Business.Domain.ValueObjects;
using Shared.Domain.Common;

namespace Business.Domain.Entities;

/// <summary>
/// A customer the tenant does business with. Unlike Asset/Transaction, this is already
/// domain-generic (a "client" means the same thing for Rental and Farming) so it is NOT
/// abstracted further. Its associated transactions are not stored here — they're looked
/// up by <c>ClientId</c> at query time (see GetClientTransactions).
/// </summary>
public class Client : Entity<Guid>
{
    public Guid TenantId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string PhoneNumber { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public Location? Location { get; private set; }
    public string? Description { get; private set; }

    private Client() { }

    public static Client Create(Guid tenantId, string name, string phoneNumber, string email, Location? location, string? description)
    {
        return new Client
        {
            Id = Guid.NewGuid(),
            TenantId = tenantId,
            Name = name,
            PhoneNumber = phoneNumber,
            Email = email,
            Location = location,
            Description = description
        };
    }

    public void Update(string name, string phoneNumber, string email, Location? location, string? description)
    {
        Name = name;
        PhoneNumber = phoneNumber;
        Email = email;
        Location = location;
        Description = description;
    }
}
