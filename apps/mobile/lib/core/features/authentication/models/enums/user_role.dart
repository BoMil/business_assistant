/// Mirrors the backend's Identity.Domain.Enums.UserRole — delivered via the
/// JWT's 'role' claim (see Identity.Infrastructure/JwtProvider.cs).
enum UserRole { owner, admin, member }

UserRole? userRoleFromString(String? raw) => switch (raw) {
      'Owner' => UserRole.owner,
      'Admin' => UserRole.admin,
      'Member' => UserRole.member,
      _ => null,
    };
