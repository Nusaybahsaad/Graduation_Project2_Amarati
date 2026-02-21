import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/maintenance_repository.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final MaintenanceRepository repository;

  MaintenanceBloc({required this.repository}) : super(MaintenanceInitial()) {
    on<LoadMaintenanceRequests>(_onLoadRequests);
    on<CreateMaintenanceRequest>(_onCreateRequest);
    on<UpdateMaintenanceStatus>(_onUpdateStatus);
    on<AssignProviderToRequest>(_onAssignProvider);
  }

  Future<void> _onLoadRequests(
    LoadMaintenanceRequests event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceLoading());
    final result = await repository.getRequests();
    result.fold(
      (failure) => emit(MaintenanceError(failure.message)),
      (requests) => emit(MaintenanceLoaded(requests)),
    );
  }

  Future<void> _onCreateRequest(
    CreateMaintenanceRequest event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceActionLoading());
    final result = await repository.createRequest(
      propertyId: event.propertyId,
      unitId: event.unitId,
      title: event.title,
      description: event.description,
      category: event.category,
      priority: event.priority,
    );
    result.fold((failure) => emit(MaintenanceError(failure.message)), (
      request,
    ) {
      emit(MaintenanceCreateSuccess(request));
      // Reload the list after creation
      add(LoadMaintenanceRequests());
    });
  }

  Future<void> _onUpdateStatus(
    UpdateMaintenanceStatus event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceActionLoading());
    final result = await repository.updateRequest(
      event.requestId,
      status: event.status,
    );
    result.fold(
      (failure) => emit(MaintenanceError(failure.message)),
      (_) => add(LoadMaintenanceRequests()),
    );
  }

  Future<void> _onAssignProvider(
    AssignProviderToRequest event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(MaintenanceActionLoading());
    final result = await repository.assignProvider(
      event.requestId,
      event.providerId,
    );
    result.fold(
      (failure) => emit(MaintenanceError(failure.message)),
      (_) => add(LoadMaintenanceRequests()),
    );
  }
}
