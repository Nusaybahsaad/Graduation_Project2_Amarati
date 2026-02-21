class ProviderModel {
  final String id;
  final String userId;
  final String companyName;
  final String serviceCategory;
  final String city;
  final double rating;
  final int totalJobs;
  final bool isVerified;
  final double? hourlyRate;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.serviceCategory,
    required this.city,
    required this.rating,
    required this.totalJobs,
    required this.isVerified,
    this.hourlyRate,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      companyName: json['company_name'] as String,
      serviceCategory: json['service_category'] as String,
      city: json['city'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalJobs: json['total_jobs'] as int,
      isVerified: json['is_verified'] as bool,
      hourlyRate: json['hourly_rate'] != null
          ? (json['hourly_rate'] as num).toDouble()
          : null,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  String get serviceCategoryLabel {
    switch (serviceCategory.toLowerCase()) {
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
        return serviceCategory;
    }
  }
}
