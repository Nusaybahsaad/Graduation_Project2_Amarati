import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../models/maintenance_request_model.dart';
import '../models/visit_log_model.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final ApiClient apiClient;

  MaintenanceRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<MaintenanceRequestModel>>> getRequests() async {
    try {
      final response = await apiClient.get(ApiEndpoints.maintenance);
      final items = (response.data['items'] as List)
          .map((json) => MaintenanceRequestModel.fromJson(json))
          .toList();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceRequestModel>> getRequest(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.maintenanceDetail(id));
      return Right(MaintenanceRequestModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceRequestModel>> createRequest({
    required String propertyId,
    String? unitId,
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.maintenance,
        data: {
          'property_id': propertyId,
          if (unitId != null) 'unit_id': unitId,
          'title': title,
          'description': description,
          'category': category,
          'priority': priority,
        },
      );
      return Right(MaintenanceRequestModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceRequestModel>> updateRequest(
    String id, {
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;

      final response = await apiClient.patch(
        ApiEndpoints.maintenanceDetail(id),
        data: data,
      );
      return Right(MaintenanceRequestModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MaintenanceRequestModel>> assignProvider(
    String requestId,
    String providerId,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.maintenanceAssign(requestId),
        data: {'provider_id': providerId},
      );
      return Right(MaintenanceRequestModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // --- VIists Operations ---

  @override
  Future<Either<Failure, List<VisitLogModel>>> getVisitLogs() async {
    try {
      final response = await apiClient.get(ApiEndpoints.visits);
      final List<dynamic> data = response.data;
      final visits = data.map((json) => VisitLogModel.fromJson(json)).toList();
      return Right(visits);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VisitLogModel>> createVisitLog({
    required String maintenanceRequestId,
    required String providerId,
    required String technicianName,
    String? notes,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.visits,
        data: {
          'maintenance_request_id': maintenanceRequestId,
          'provider_id': providerId,
          'technician_name': technicianName,
          if (notes != null) 'notes': notes,
        },
      );
      return Right(VisitLogModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VisitLogModel>> updateVisitStatus({
    required String visitId,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await apiClient.patch(
        '${ApiEndpoints.visits}$visitId/status',
        data: {'status': status, if (notes != null) 'notes': notes},
      );
      return Right(VisitLogModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
