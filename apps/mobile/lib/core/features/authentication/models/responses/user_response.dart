import 'package:business_assistant/core/features/authentication/models/enums/user_role.dart';

/// Response body from GET /identity/users/me.
class UserResponse {
  String id = '';
  String tenantId = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  UserRole? role;
  String? imgUrl;

  UserResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    tenantId = json['tenantId'] ?? '';
    firstName = json['firstName'] ?? '';
    lastName = json['lastName'] ?? '';
    email = json['email'] ?? '';
    role = userRoleFromString(json['role']);
    imgUrl = json['imgUrl'];
  }
}
