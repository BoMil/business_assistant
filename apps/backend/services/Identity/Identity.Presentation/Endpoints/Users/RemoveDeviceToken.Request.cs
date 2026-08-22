namespace Identity.Presentation.Endpoints.Users;

/// <summary>JSON body for DELETE /users/me/device-tokens.</summary>
public record RemoveDeviceTokenRequest(string Token);
