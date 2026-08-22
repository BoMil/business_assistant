using System.Collections.Concurrent;
using FirebaseAdmin;

namespace Identity.Infrastructure.PushNotifications;

/// <summary>
/// Each tenant has its own Firebase project, so unlike Shared.Infrastructure's single
/// shared BlobServiceClient, there's one FirebaseApp per tenant here — built lazily on
/// first send and cached for reuse. Registered as a singleton, but nothing is
/// constructed at startup: entries are only added on demand (see
/// FirebasePushNotificationService), so a tenant with no/bad Firebase config never
/// affects any other tenant or startup itself.
/// </summary>
internal sealed class FirebaseAppCache
{
    public ConcurrentDictionary<Guid, FirebaseApp> Apps { get; } = new();
}
