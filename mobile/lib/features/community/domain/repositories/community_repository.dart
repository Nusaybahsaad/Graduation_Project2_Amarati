import '../../data/models/chat_room_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/announcement_model.dart';

abstract class CommunityRepository {
  Future<List<AnnouncementModel>> getAnnouncements(String propertyId);
  Future<AnnouncementModel> createAnnouncement(
    String propertyId,
    String title,
    String content,
  );

  Future<List<ChatRoomModel>> getRooms(String propertyId);
  Future<ChatRoomModel> createRoom(
    String propertyId,
    String name,
    String roomType,
  );

  Future<List<ChatMessageModel>> getMessages(
    String roomId, {
    int skip = 0,
    int limit = 50,
  });
  Future<ChatMessageModel> sendMessage(String roomId, String content);
}
