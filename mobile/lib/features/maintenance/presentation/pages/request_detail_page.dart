import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/maintenance_request_model.dart';
import '../../data/models/visit_log_model.dart';
import 'package:intl/intl.dart';

class RequestDetailPage extends StatelessWidget {
  final MaintenanceRequestModel request;

  const RequestDetailPage({super.key, required this.request});

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تفاصيل الطلب',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _statusColor(request.status).withOpacity(0.15),
                    _statusColor(request.status).withOpacity(0.05),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _statusColor(request.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _statusColor(request.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _categoryIcon(request.category),
                      color: _statusColor(request.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: _statusColor(request.status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              request.statusLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(request.status),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Cards
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: 'التصنيف',
                    value: request.categoryLabel,
                    icon: Icons.category,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(
                    label: 'الأولوية',
                    value: request.priorityLabel,
                    icon: Icons.flag,
                    valueColor: _priorityColor(request.priority),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description Section
            const Text(
              'وصف المشكلة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                request.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timeline Section
            const Text(
              'المخطط الزمني',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _TimelineStep(
              title: 'تم الإنشاء',
              subtitle:
                  '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
              isCompleted: true,
              isFirst: true,
            ),
            _TimelineStep(
              title: 'تم التعيين',
              subtitle: request.providerId != null
                  ? 'تم تعيين مقدم خدمة'
                  : 'في انتظار التعيين',
              isCompleted: [
                'ASSIGNED',
                'IN_PROGRESS',
                'COMPLETED',
                'CLOSED',
              ].contains(request.status),
            ),
            _TimelineStep(
              title: 'قيد التنفيذ',
              subtitle: '',
              isCompleted: [
                'IN_PROGRESS',
                'COMPLETED',
                'CLOSED',
              ].contains(request.status),
            ),
            _TimelineStep(
              title: 'مكتمل',
              subtitle: '',
              isCompleted: ['COMPLETED', 'CLOSED'].contains(request.status),
              isLast: true,
            ),

            // Provider Info (if assigned)
            if (request.providerId != null) ...[
              const SizedBox(height: 24),
              const Text(
                'مقدم الخدمة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.handyman,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'تم تعيين مقدم خدمة',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Visit Logs Section (if any)
            if (request.visits != null && request.visits!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'سجل الزيارات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...request.visits!.map((visit) => _VisitLogCard(visit: visit)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitLogCard extends StatelessWidget {
  final VisitLogModel visit;

  const _VisitLogCard({required this.visit});

  String _formatStatus(String status) {
    switch (status) {
      case 'SCHEDULED':
        return 'مجدولة';
      case 'EN_ROUTE':
        return 'في الطريق';
      case 'IN_PROGRESS':
        return 'قيد التنفيذ';
      case 'COMPLETED':
        return 'مكتملة';
      case 'CANCELLED':
        return 'ملغاة';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'SCHEDULED':
        return AppColors.info;
      case 'EN_ROUTE':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الفني: ${visit.technicianName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(visit.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatStatus(visit.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(visit.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                'الإنشاء: ${DateFormat.yMMMd('ar').add_jm().format(visit.createdAt)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (visit.notes != null && visit.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                visit.notes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
