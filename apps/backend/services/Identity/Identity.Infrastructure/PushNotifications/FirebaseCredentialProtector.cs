using Identity.Application.Services;
using Microsoft.AspNetCore.DataProtection;

namespace Identity.Infrastructure.PushNotifications;

/// <summary>
/// Encrypts a tenant's Firebase Admin SDK service-account JSON before it's stored, using
/// ASP.NET Core's built-in Data Protection. The key ring is persisted to a dedicated Azure
/// Blob container (see Identity.Infrastructure/DependencyInjection.cs) instead of local disk,
/// so it survives container restarts/redeploys/scale-to-zero.
/// </summary>
internal sealed class FirebaseCredentialProtector(IDataProtectionProvider dataProtectionProvider) : IFirebaseCredentialProtector
{
    private readonly IDataProtector _protector = dataProtectionProvider.CreateProtector("Identity.FirebaseServiceAccount");

    public string Protect(string plaintextServiceAccountJson) => _protector.Protect(plaintextServiceAccountJson);

    public string Unprotect(string encryptedServiceAccountJson) => _protector.Unprotect(encryptedServiceAccountJson);
}
