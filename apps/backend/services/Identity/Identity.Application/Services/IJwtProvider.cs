using Identity.Domain.Entities;

namespace Identity.Application.Services;

public interface IJwtProvider
{
    string GenerateAccessToken(User user);
    string GenerateRefreshToken();
}
