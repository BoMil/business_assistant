namespace Identity.Presentation.Endpoints.Auth.RefreshToken;

/// <summary>JSON body for POST /auth/refresh-token.</summary>
public record RefreshTokenRequest(string Token);
