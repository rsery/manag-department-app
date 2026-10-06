enum UserRole { admin, secretary, employee, principal }

// ─── helper لتحويل String من Firestore → UserRole ───
UserRole? parseUserRole(String? role) {
  switch (role?.toLowerCase().trim()) {
    case 'admin':
      return UserRole.admin;
    case 'secretary':
      return UserRole.secretary;
    case 'employee':
      return UserRole.employee;
    case 'principal':
      return UserRole.principal;
    default:
      return null;
  }
}
