import '../services/auth_service.dart';

class AppUser {
  final String uid;
  final AuthRole role;
  final String displayName;
  final String? email;
  final String? employeeId;
  final String? mobile;
  final String? department;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.role,
    required this.displayName,
    this.email,
    this.employeeId,
    this.mobile,
    this.department,
    this.photoUrl,
  });
}
