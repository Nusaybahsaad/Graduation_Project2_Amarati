import 'package:equatable/equatable.dart';
import '../../data/models/maintenance_request_model.dart';

abstract class MaintenanceState extends Equatable {
  const MaintenanceState();
  @override
  List<Object?> get props => [];
}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {}

class MaintenanceLoaded extends MaintenanceState {
  final List<MaintenanceRequestModel> requests;

  const MaintenanceLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class MaintenanceError extends MaintenanceState {
  final String message;

  const MaintenanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class MaintenanceCreateSuccess extends MaintenanceState {
  final MaintenanceRequestModel request;

  const MaintenanceCreateSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class MaintenanceActionLoading extends MaintenanceState {}
