enum TypeRequest { admin, technical }

// ─── helper لتحويل String من Firestore → UserRole ───
TypeRequest? parseUserRole(String? role) {
  switch (role?.toLowerCase().trim()) {
    case 'admin':
      return TypeRequest.admin;
    case 'technical':
      return TypeRequest.technical;
    default:
      return null;
  }
}
