import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class FetchAnnouncementsEvent extends CommunityEvent {
  final String propertyId;
  const FetchAnnouncementsEvent(this.propertyId);
  @override
  List<Object?> get props => [propertyId];
}

class FetchRoomsEvent extends CommunityEvent {
  final String propertyId;
  const FetchRoomsEvent(this.propertyId);
  @override
  List<Object?> get props => [propertyId];
}

class FetchMessagesEvent extends CommunityEvent {
  final String roomId;
  const FetchMessagesEvent(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class SendMessageEvent extends CommunityEvent {
  final String roomId;
  final String content;
  const SendMessageEvent(this.roomId, this.content);
  @override
  List<Object?> get props => [roomId, content];
}

class CreateAnnouncementEvent extends CommunityEvent {
  final String propertyId;
  final String title;
  final String content;
  const CreateAnnouncementEvent(this.propertyId, this.title, this.content);
  @override
  List<Object?> get props => [propertyId, title, content];
}

class CreateRoomEvent extends CommunityEvent {
  final String propertyId;
  final String name;
  final String roomType;
  const CreateRoomEvent(this.propertyId, this.name, this.roomType);
  @override
  List<Object?> get props => [propertyId, name, roomType];
}
