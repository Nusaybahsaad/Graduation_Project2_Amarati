class ChatRoomModel {
  final String id;
  final String propertyId;
  final String name;
  final String roomType;
  final DateTime createdAt;

  ChatRoomModel({
    required this.id,
    required this.propertyId,
    required this.name,
    required this.roomType,
    required this.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      name: json['name'] as String,
      roomType: json['room_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
