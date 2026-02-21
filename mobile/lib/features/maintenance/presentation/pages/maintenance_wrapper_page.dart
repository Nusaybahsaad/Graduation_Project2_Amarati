import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/maintenance_request_model.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';
import 'create_request_page.dart';
import 'request_detail_page.dart';

class MaintenanceWrapperPage extends StatelessWidget {
  const MaintenanceWrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MaintenanceBloc>()..add(LoadMaintenanceRequests()),
      child: const _MaintenanceListView(),
    );
  }
}

class _MaintenanceListView extends StatelessWidget {
  const _MaintenanceListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'طلبات الصيانة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<MaintenanceBloc>(),
                child: const CreateRequestPage(),
              ),
            ),
          );
          if (result == true) {
            context.read<MaintenanceBloc>().add(LoadMaintenanceRequests());
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
      ),
      body: BlocBuilder<MaintenanceBloc, MaintenanceState>(
        builder: (context, state) {
          if (state is MaintenanceLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is MaintenanceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MaintenanceBloc>().add(
                      LoadMaintenanceRequests(),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is MaintenanceLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'لا توجد طلبات صيانة',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'اضغط + لإنشاء طلب جديد',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MaintenanceBloc>().add(LoadMaintenanceRequests());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  return _RequestCard(request: state.requests[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final MaintenanceRequestModel request;

  const _RequestCard({required this.request});

  Color _statusColor(String status) {
    switch (status) {
      case 'OPEN':
        return AppColors.info;
      case 'ASSIGNED':
        return AppColors.warning;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return AppColors.success;
      case 'CLOSED':
        return AppColors.textHint;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'EMERGENCY':
        return AppColors.error;
      case 'HIGH':
        return Colors.deepOrange;
      case 'MEDIUM':
        return AppColors.warning;
      case 'LOW':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'hvac':
        return Icons.ac_unit;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'painting':
        return Icons.format_paint;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<MaintenanceBloc>(),
                child: RequestDetailPage(request: request),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _statusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon(request.category),
                      color: _statusColor(request.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.categoryLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _priorityColor(request.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.priorityLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _priorityColor(request.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description preview
              Text(
                request.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer: status + date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: _statusColor(request.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          request.statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(request.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
