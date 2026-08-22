namespace Identity.Domain.Entities;

/// <summary>
/// Each tenant has its own Firebase project for push notifications. The five
/// non-secret fields mirror a client FirebaseOptions/google-services.json —
/// safe to hand back to the mobile CI build (see TenantConfigDto). The
/// service-account credential used to actually send pushes is a real secret
/// and is stored encrypted (see IFirebaseCredentialProtector) — never exposed
/// through any read endpoint.
/// </summary>
public class FirebaseConfig
{
    public string AndroidApiKey { get; set; } = string.Empty;
    public string AndroidAppId { get; set; } = string.Empty;
    public string ProjectId { get; set; } = string.Empty;
    public string MessagingSenderId { get; set; } = string.Empty;
    public string StorageBucket { get; set; } = string.Empty;
    public string EncryptedServiceAccountJson { get; set; } = string.Empty;
}
