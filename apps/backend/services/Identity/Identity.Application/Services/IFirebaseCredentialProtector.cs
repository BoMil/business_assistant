namespace Identity.Application.Services;

/// <summary>Encrypts/decrypts a tenant's Firebase Admin SDK service-account JSON before it's
/// persisted — kept dependency-free here so Application doesn't need a DataProtection
/// package reference; the implementation lives in Identity.Infrastructure.</summary>
public interface IFirebaseCredentialProtector
{
    string Protect(string plaintextServiceAccountJson);
    string Unprotect(string encryptedServiceAccountJson);
}
