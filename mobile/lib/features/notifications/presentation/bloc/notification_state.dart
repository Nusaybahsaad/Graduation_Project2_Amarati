import 'package:equatable/equatable.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final NotificationPreferenceModel? preferences;

  const NotificationLoaded({required this.notifications, this.preferences});

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    NotificationPreferenceModel? preferences,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [notifications, preferences];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
