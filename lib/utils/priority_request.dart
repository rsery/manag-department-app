enum PriorityRequest { urgent, normal, future }

// ─── helper لتحويل String من Firestore → UserRole ───
PriorityRequest? parseUserRole(String? role) {
  switch (role?.toLowerCase().trim()) {
    case 'urgent':
      return PriorityRequest.urgent;
    case 'normal':
      return PriorityRequest.normal;
    case 'future':
      return PriorityRequest.future;
    default:
      return null;
  }
}
