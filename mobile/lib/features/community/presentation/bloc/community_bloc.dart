import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/community_repository.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository repository;

  CommunityBloc({required this.repository}) : super(CommunityInitial()) {
    on<FetchAnnouncementsEvent>(_onFetchAnnouncements);
    on<FetchRoomsEvent>(_onFetchRooms);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<CreateAnnouncementEvent>(_onCreateAnnouncement);
    on<CreateRoomEvent>(_onCreateRoom);
  }

  Future<void> _onFetchAnnouncements(
    FetchAnnouncementsEvent event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      final data = await repository.getAnnouncements(event.propertyId);
      emit(AnnouncementsLoaded(data));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onFetchRooms(
    FetchRoomsEvent event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      final data = await repository.getRooms(event.propertyId);
      emit(RoomsLoaded(data));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<CommunityState> emit,
  ) async {
    // Note: To avoid screen flicker for polling, we might skip CommunityLoading if state is already MessagesLoaded
    if (state is! MessagesLoaded) {
      emit(CommunityLoading());
    }
    try {
      final data = await repository.getMessages(event.roomId, limit: 100);
      emit(MessagesLoaded(event.roomId, data));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      await repository.sendMessage(event.roomId, event.content);
      // Re-fetch messages silently without going back to loading screen mostly
      add(FetchMessagesEvent(event.roomId));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onCreateAnnouncement(
    CreateAnnouncementEvent event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      await repository.createAnnouncement(
        event.propertyId,
        event.title,
        event.content,
      );
      emit(CommunityOperationSuccess());
      add(FetchAnnouncementsEvent(event.propertyId));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<CommunityState> emit,
  ) async {
    emit(CommunityLoading());
    try {
      await repository.createRoom(event.propertyId, event.name, event.roomType);
      emit(CommunityOperationSuccess());
      add(FetchRoomsEvent(event.propertyId));
    } catch (e) {
      emit(CommunityError(e.toString()));
    }
  }
}
