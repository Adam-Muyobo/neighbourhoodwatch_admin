enum PlatformType { mobile, desktop }

enum UserRole { admin, officer, member }

enum UserStatus { active, inactive, suspended, blocked }

PlatformType platformFromWidth(double width) {
  if (width >= 1024) return PlatformType.desktop;
  return PlatformType.mobile;
}

String platformToString(PlatformType p) =>
    p == PlatformType.mobile ? 'Mobile' : 'Desktop/Web';

String roleToString(UserRole r) {
  switch (r) {
    case UserRole.admin:
      return 'ADMIN';
    case UserRole.officer:
      return 'OFFICER';
    case UserRole.member:
      return 'MEMBER';
  }
}

String statusToString(UserStatus s) {
  switch (s) {
    case UserStatus.active:
      return 'ACTIVE';
    case UserStatus.inactive:
      return 'INACTIVE';
    case UserStatus.suspended:
      return 'SUSPENDED';
    case UserStatus.blocked:
      return 'BLOCKED';
  }
}

UserStatus stringToStatus(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
      return UserStatus.active;
    case 'INACTIVE':
      return UserStatus.inactive;
    case 'SUSPENDED':
      return UserStatus.suspended;
    case 'BLOCKED':
      return UserStatus.blocked;
    default:
      return UserStatus.inactive;
  }
}

UserRole stringToRole(String role) {
  switch (role.toUpperCase()) {
    case 'ADMIN':
      return UserRole.admin;
    case 'OFFICER':
      return UserRole.officer;
    case 'MEMBER':
      return UserRole.member;
    default:
      return UserRole.member;
  }
}