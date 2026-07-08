namespace Identity.Presentation.Endpoints.Auth.Login;

/// <summary>
/// JSON body for POST /auth/login.
/// Kept separate from LoginCommand (Application layer) so that the HTTP contract
/// can evolve independently — e.g. renaming a field here doesn't affect the handler.
/// </summary>
public record LoginRequest(string Email, string Password);
