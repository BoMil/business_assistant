namespace Identity.Presentation.Endpoints.Users;

/// <summary>JSON body for POST /users/me/device-tokens.</summary>
public record RegisterDeviceTokenRequest(string Token);
