import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<LoadNotificationPreferences>(_onLoadPreferences);
    on<UpdateNotificationPreferences>(_onUpdatePreferences);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final noticesResult = await repository.getNotifications();

    noticesResult.fold(
      (Failure failure) => emit(NotificationError(failure.message)),
      (List<NotificationModel> notifications) {
        if (state is NotificationLoaded) {
          final currentState = state as NotificationLoaded;
          emit(currentState.copyWith(notifications: notifications));
        } else {
          emit(NotificationLoaded(notifications: notifications));
          add(LoadNotificationPreferences());
        }
      },
    );
  }

  Future<void> _onLoadPreferences(
    LoadNotificationPreferences event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.getPreferences();
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      result.fold(
        (
          Failure failure,
        ) {}, // Ignore preference load error silently to keep notices showing
        (NotificationPreferenceModel preferences) =>
            emit(currentState.copyWith(preferences: preferences)),
      );
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.markAsRead(event.notificationId);

    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      result.fold(
        (Failure failure) => emit(NotificationError(failure.message)),
        (NotificationModel notification) {
          // Update the specific notification locally
          final updatedNotices = currentState.notifications
              .map((n) => n.id == notification.id ? notification : n)
              .toList();
          emit(currentState.copyWith(notifications: updatedNotices));
        },
      );
    }
  }

  Future<void> _onUpdatePreferences(
    UpdateNotificationPreferences event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.updatePreferences(
      emailEnabled: event.emailEnabled,
      pushEnabled: event.pushEnabled,
    );

    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      result.fold(
        (Failure failure) => emit(NotificationError(failure.message)),
        (NotificationPreferenceModel preferences) {
          emit(currentState.copyWith(preferences: preferences));
          emit(
            const NotificationActionSuccess('تم تحديث إعدادات الإشعارات بنجاح'),
          );
        },
      );
    }
  }
}
