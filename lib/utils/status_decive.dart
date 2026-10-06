enum DeviceStatus {
  available, // سليم
  maintenance, // قيد الصيانة
  broken, // تالف
}

// ─── helper لتحويل String من Firestore → DeviceStatus ───
DeviceStatus? parseDeviceStatus(String? status) {
  switch (status?.toLowerCase().trim()) {
    case 'available':
      return DeviceStatus.available;

    case 'maintenance':
      return DeviceStatus.maintenance;

    case 'broken':
      return DeviceStatus.broken;

    default:
      return null;
  }
}
