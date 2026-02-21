import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  Future<Either<Failure, NotificationModel>> markAsRead(String id);
  Future<Either<Failure, NotificationPreferenceModel>> getPreferences();
  Future<Either<Failure, NotificationPreferenceModel>> updatePreferences({
    bool? emailEnabled,
    bool? pushEnabled,
  });
}
