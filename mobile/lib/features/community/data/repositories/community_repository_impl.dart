import '../../../../core/network/api_client.dart';
import '../../domain/repositories/community_repository.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';
import '../models/announcement_model.dart';
import 'package:dio/dio.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final ApiClient apiClient;

  CommunityRepositoryImpl({required this.apiClient});

  @override
  Future<List<AnnouncementModel>> getAnnouncements(String propertyId) async {
    try {
      final response = await apiClient.get(
        '/community/properties/$propertyId/announcements',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => AnnouncementModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load announcements');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<AnnouncementModel> createAnnouncement(
    String propertyId,
    String title,
    String content,
  ) async {
    try {
      final response = await apiClient.post(
        '/community/properties/$propertyId/announcements',
        data: {'title': title, 'content': content},
      );
      if (response.statusCode == 201) {
        return AnnouncementModel.fromJson(response.data);
      }
      throw Exception('Failed to create announcement');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Network error');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<ChatRoomModel>> getRooms(String propertyId) async {
    try {
      final response = await apiClient.get(
        '/community/properties/$propertyId/rooms',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => ChatRoomModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load rooms');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<ChatRoomModel> createRoom(
    String propertyId,
    String name,
    String roomType,
  ) async {
    try {
      final response = await apiClient.post(
        '/community/properties/$propertyId/rooms',
        data: {'name': name, 'room_type': roomType},
      );
      if (response.statusCode == 201) {
        return ChatRoomModel.fromJson(response.data);
      }
      throw Exception('Failed to create room');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Network error');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(
    String roomId, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get(
        '/community/rooms/$roomId/messages',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data['messages'];
        return messagesData.map((e) => ChatMessageModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load messages');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(String roomId, String content) async {
    try {
      final response = await apiClient.post(
        '/community/rooms/$roomId/messages',
        data: {'content': content},
      );
      if (response.statusCode == 201) {
        return ChatMessageModel.fromJson(response.data);
      }
      throw Exception('Failed to send message');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Network error');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
