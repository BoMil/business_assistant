namespace Identity.Application.Services;

public interface IPushNotificationService
{
    Task<bool> SendAsync(
        Guid tenantId,
        string deviceToken,
        string title,
        string body,
        Dictionary<string, string>? data = null,
        CancellationToken cancellationToken = default);
}
