class VisitLogModel {
  final String id;
  final String maintenanceRequestId;
  final String providerId;
  final String status;
  final String? technicianName;
  final String? notes;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VisitLogModel({
    required this.id,
    required this.maintenanceRequestId,
    required this.providerId,
    required this.status,
    this.technicianName,
    this.notes,
    this.startTime,
    this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VisitLogModel.fromJson(Map<String, dynamic> json) {
    return VisitLogModel(
      id: json['id'] as String,
      maintenanceRequestId: json['maintenance_request_id'] as String,
      providerId: json['provider_id'] as String,
      status: json['status'] as String,
      technicianName: json['technician_name'] as String?,
      notes: json['notes'] as String?,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'ON_THE_WAY':
        return 'في الطريق';
      case 'ARRIVED':
        return 'وصل للموقع';
      case 'WORK_STARTED':
        return 'بدأ العمل';
      case 'COMPLETED':
        return 'العمل مكتمل';
      default:
        return status;
    }
  }
}
