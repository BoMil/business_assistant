using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Identity.Application.Repositories;
using Identity.Application.Services;

namespace Identity.Infrastructure.PushNotifications;

/// <summary>
/// v1 gap, kept on purpose: an Unregistered/InvalidArgument FCM error (stale/uninstalled
/// token) doesn't prune the DeviceToken row here — that cleanup is natural once there's
/// real send volume; speculative for an infra-only pass whose only sender is a manual
/// test button.
/// </summary>
internal sealed class FirebasePushNotificationService(
    FirebaseAppCache appCache,
    IUnitOfWorkIdentity unitOfWork,
    IFirebaseCredentialProtector protector) : IPushNotificationService
{
    public async Task<bool> SendAsync(
        Guid tenantId,
        string deviceToken,
        string title,
        string body,
        Dictionary<string, string>? data = null,
        CancellationToken cancellationToken = default)
    {
        var app = await GetOrCreateAppAsync(tenantId, cancellationToken);

        try
        {
            await FirebaseMessaging.GetMessaging(app).SendAsync(
                new Message
                {
                    // Message.Fid (Firebase Installation ID) is the SDK's newer recommendation,
                    // but the mobile client (firebase_messaging's getToken()) still produces a
                    // classic FCM registration token, not a FID — Token is the correct field here.
                    Token = deviceToken,
                    Notification = new Notification { Title = title, Body = body },
                    Data = data
                },
                cancellationToken);
            return true;
        }
        catch (FirebaseMessagingException)
        {
            return false;
        }
    }

    private async Task<FirebaseApp> GetOrCreateAppAsync(Guid tenantId, CancellationToken cancellationToken)
    {
        if (appCache.Apps.TryGetValue(tenantId, out var cachedApp))
            return cachedApp;

        var tenant = await unitOfWork.Tenants.GetByIdAsync(tenantId, cancellationToken)
            ?? throw new InvalidOperationException($"Tenant '{tenantId}' not found.");

        if (string.IsNullOrEmpty(tenant.FirebaseConfig.EncryptedServiceAccountJson))
            throw new InvalidOperationException($"Tenant '{tenantId}' has no Firebase config set.");

        var serviceAccountJson = protector.Unprotect(tenant.FirebaseConfig.EncryptedServiceAccountJson);
        var credential = CredentialFactory.FromJson<ServiceAccountCredential>(serviceAccountJson).ToGoogleCredential();
        var options = new AppOptions { Credential = credential };

        try
        {
            var app = FirebaseApp.Create(options, tenantId.ToString());
            appCache.Apps.TryAdd(tenantId, app);
            return app;
        }
        catch (ArgumentException)
        {
            // Another concurrent call already created it under this name — reuse it.
            var app = FirebaseApp.GetInstance(tenantId.ToString());
            appCache.Apps.TryAdd(tenantId, app);
            return app;
        }
    }
}
