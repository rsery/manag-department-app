enum StatusRequest {
  pending, // معلقة
  inProgress, // جارية
  completed, // مكتملة
  rejected,
}

// ─── helper لتحويل String من Firestore → UserRole ───
StatusRequest? parseUserRole(String? role) {
  switch (role?.toLowerCase().trim()) {
    case 'pending':
      return StatusRequest.pending;
    case 'inProgress':
      return StatusRequest.inProgress;
    case 'completed':
      return StatusRequest.completed;
    case 'rejected':
      return StatusRequest.rejected;
    default:
      return null;
  }
}
