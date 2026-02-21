class AnnouncementModel {
  final String id;
  final String propertyId;
  final String authorId;
  final String title;
  final String content;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.propertyId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
