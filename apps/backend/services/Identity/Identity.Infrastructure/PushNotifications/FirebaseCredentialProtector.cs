using Identity.Application.Services;
using Microsoft.AspNetCore.DataProtection;

namespace Identity.Infrastructure.PushNotifications;

/// <summary>
/// Encrypts a tenant's Firebase Admin SDK service-account JSON before it's stored, using
/// ASP.NET Core's built-in Data Protection (no new infra needed). Caveat: the default key
/// ring persists to local disk per instance — fine for local dev/a single long-lived
/// instance, but a multi-instance/redeployed-container deployment needs a shared key-ring
/// store (e.g. PersistKeysToAzureBlobStorage + ProtectKeysWithAzureKeyVault) — the same
/// already-tracked Key Vault gap noted elsewhere in this codebase, not solved here.
/// </summary>
internal sealed class FirebaseCredentialProtector(IDataProtectionProvider dataProtectionProvider) : IFirebaseCredentialProtector
{
    private readonly IDataProtector _protector = dataProtectionProvider.CreateProtector("Identity.FirebaseServiceAccount");

    public string Protect(string plaintextServiceAccountJson) => _protector.Protect(plaintextServiceAccountJson);

    public string Unprotect(string encryptedServiceAccountJson) => _protector.Unprotect(encryptedServiceAccountJson);
}
