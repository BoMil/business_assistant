using Identity.Application.Services;

namespace Identity.Infrastructure;

/// <summary>
/// BCrypt implementation of <see cref="IPasswordHasher"/>.
/// BCrypt automatically salts the hash, so two calls with the same password produce different hashes —
/// that's why Verify() must be used instead of re-hashing and comparing directly.
/// </summary>
internal sealed class PasswordHasher : IPasswordHasher
{
    public string Hash(string password) =>
        BCrypt.Net.BCrypt.HashPassword(password);

    public bool Verify(string password, string hash) =>
        BCrypt.Net.BCrypt.Verify(password, hash);
}
