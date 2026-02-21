import 'package:equatable/equatable.dart';

abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadMaintenanceRequests extends MaintenanceEvent {}

class CreateMaintenanceRequest extends MaintenanceEvent {
  final String propertyId;
  final String? unitId;
  final String title;
  final String description;
  final String category;
  final String priority;

  const CreateMaintenanceRequest({
    required this.propertyId,
    this.unitId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });

  @override
  List<Object?> get props => [
    propertyId,
    unitId,
    title,
    description,
    category,
    priority,
  ];
}

class UpdateMaintenanceStatus extends MaintenanceEvent {
  final String requestId;
  final String status;

  const UpdateMaintenanceStatus({
    required this.requestId,
    required this.status,
  });

  @override
  List<Object?> get props => [requestId, status];
}

class AssignProviderToRequest extends MaintenanceEvent {
  final String requestId;
  final String providerId;

  const AssignProviderToRequest({
    required this.requestId,
    required this.providerId,
  });

  @override
  List<Object?> get props => [requestId, providerId];
}
