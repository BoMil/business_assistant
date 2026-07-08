using Shared.Application.RequestTypes;

namespace Identity.Application.UseCases.RefreshToken;

public record RefreshTokenCommand(string Token) : ICommand<RefreshTokenResult>;

public record RefreshTokenResult(string AccessToken, string RefreshToken);
