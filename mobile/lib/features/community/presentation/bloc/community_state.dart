import 'package:equatable/equatable.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/announcement_model.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class AnnouncementsLoaded extends CommunityState {
  final List<AnnouncementModel> announcements;
  const AnnouncementsLoaded(this.announcements);
  @override
  List<Object?> get props => [announcements];
}

class RoomsLoaded extends CommunityState {
  final List<ChatRoomModel> rooms;
  const RoomsLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class MessagesLoaded extends CommunityState {
  final List<ChatMessageModel> messages;
  final String roomId;
  const MessagesLoaded(this.roomId, this.messages);
  @override
  List<Object?> get props => [roomId, messages];
}

class CommunityOperationSuccess extends CommunityState {}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);
  @override
  List<Object?> get props => [message];
}
