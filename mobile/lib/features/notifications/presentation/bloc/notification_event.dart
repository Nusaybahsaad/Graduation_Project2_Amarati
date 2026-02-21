import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class LoadNotificationPreferences extends NotificationEvent {}

class UpdateNotificationPreferences extends NotificationEvent {
  final bool? emailEnabled;
  final bool? pushEnabled;

  const UpdateNotificationPreferences({this.emailEnabled, this.pushEnabled});

  @override
  List<Object?> get props => [emailEnabled, pushEnabled];
}
