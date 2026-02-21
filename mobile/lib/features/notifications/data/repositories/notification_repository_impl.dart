import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient apiClient;

  NotificationRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final response = await apiClient.get(ApiEndpoints.notifications);
      final List<dynamic> data = response.data;
      final notifications = data
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> markAsRead(String id) async {
    try {
      final response = await apiClient.patch(
        '${ApiEndpoints.notifications}$id/read',
        data: {'is_read': true},
      );
      return Right(NotificationModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferenceModel>> getPreferences() async {
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.notifications}preferences',
      );
      return Right(NotificationPreferenceModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferenceModel>> updatePreferences({
    bool? emailEnabled,
    bool? pushEnabled,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (emailEnabled != null) data['email_enabled'] = emailEnabled;
      if (pushEnabled != null) data['push_enabled'] = pushEnabled;

      final response = await apiClient.patch(
        '${ApiEndpoints.notifications}preferences',
        data: data,
      );
      return Right(NotificationPreferenceModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
