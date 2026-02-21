import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/maintenance_request_model.dart';
import '../../data/models/visit_log_model.dart';

abstract class MaintenanceRepository {
  Future<Either<Failure, List<MaintenanceRequestModel>>> getRequests();
  Future<Either<Failure, MaintenanceRequestModel>> getRequest(String id);
  Future<Either<Failure, MaintenanceRequestModel>> createRequest({
    required String propertyId,
    String? unitId,
    required String title,
    required String description,
    required String category,
    required String priority,
  });
  Future<Either<Failure, MaintenanceRequestModel>> updateRequest(
    String id, {
    String? status,
  });
  Future<Either<Failure, MaintenanceRequestModel>> assignProvider(
    String requestId,
    String providerId,
  );

  // Visits Methods
  Future<Either<Failure, List<VisitLogModel>>> getVisitLogs();
  Future<Either<Failure, VisitLogModel>> createVisitLog({
    required String maintenanceRequestId,
    required String providerId,
    required String technicianName,
    String? notes,
  });
  Future<Either<Failure, VisitLogModel>> updateVisitStatus({
    required String visitId,
    required String status,
    String? notes,
  });
}
