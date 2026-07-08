using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Identity.Application.Services;
using Identity.Domain.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace Identity.Infrastructure;

/// <summary>
/// JWT implementation of <see cref="IJwtProvider"/>.
/// Reads Jwt:Secret, Jwt:Issuer, Jwt:Audience, and Jwt:ExpiryMinutes from configuration (appsettings.json).
/// </summary>
internal sealed class JwtProvider(IConfiguration configuration) : IJwtProvider
{
    public string GenerateAccessToken(User user)
    {
        // Claims are key-value pairs embedded inside the token payload.
        // The client can read them without contacting the server (the token is self-contained).
        // "sub" = subject (standard JWT claim for the user's unique ID)
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim("role", user.Role.ToString()),
            new Claim("tenantId", user.TenantId.ToString())
        };

        // The secret is used to sign the token with HMAC-SHA256.
        // Anyone with this secret can forge tokens, so it must never be exposed publicly.
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Secret"]!));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expiry = DateTime.UtcNow.AddMinutes(double.Parse(configuration["Jwt:ExpiryMinutes"]!));

        var token = new JwtSecurityToken(
            issuer: configuration["Jwt:Issuer"],
            audience: configuration["Jwt:Audience"],
            claims: claims,
            expires: expiry,
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public string GenerateRefreshToken()
    {
        // The refresh token is an opaque random string — it carries no data.
        // It is stored in the database and exchanged for a new access token when the access token expires.
        // 64 random bytes → 86-character Base64 string, cryptographically secure.
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes);
    }
}
