import 'visit_log_model.dart';

class MaintenanceRequestModel {
  final String id;
  final String propertyId;
  final String? unitId;
  final String creatorId;
  final String? providerId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final List<String>? images;
  final List<VisitLogModel>? visits;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRequestModel({
    required this.id,
    required this.propertyId,
    this.unitId,
    required this.creatorId,
    this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.images,
    this.visits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      unitId: json['unit_id'] as String?,
      creatorId: json['creator_id'] as String,
      providerId: json['provider_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      visits: (json['visits'] as List?)
          ?.map((v) => VisitLogModel.fromJson(v))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'property_id': propertyId,
      if (unitId != null) 'unit_id': unitId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      if (images != null) 'images': images,
    };
  }

  /// Returns a color-friendly status label
  String get statusLabel {
    switch (status) {
      case 'OPEN':
        return 'مفتوح';
      case 'ASSIGNED':
        return 'تم التعيين';
      case 'IN_PROGRESS':
        return 'قيد التنفيذ';
      case 'COMPLETED':
        return 'مكتمل';
      case 'CLOSED':
        return 'مغلق';
      default:
        return status;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'LOW':
        return 'منخفض';
      case 'MEDIUM':
        return 'متوسط';
      case 'HIGH':
        return 'مرتفع';
      case 'EMERGENCY':
        return 'طارئ';
      default:
        return priority;
    }
  }

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return 'سباكة';
      case 'electrical':
        return 'كهرباء';
      case 'hvac':
        return 'تكييف';
      case 'cleaning':
        return 'تنظيف';
      case 'painting':
        return 'دهان';
      case 'general':
        return 'عام';
      default:
        return category;
    }
  }
}
