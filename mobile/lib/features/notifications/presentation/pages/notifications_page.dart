import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open preferences modal
              _showPreferencesModal(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(LoadNotifications());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  final isRead = notification.isRead;

                  return Container(
                    color: isRead
                        ? Colors.transparent
                        : AppColors.primary.withOpacity(0.05),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isRead
                            ? Colors.grey[200]
                            : AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          _getIconForType(notification.type),
                          color: isRead ? Colors.grey[600] : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(notification.message),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMd(
                              'ar',
                            ).add_jm().format(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (!isRead) {
                          context.read<NotificationBloc>().add(
                            MarkNotificationAsRead(notification.id),
                          );
                        }
                        // Navigate to specific entity if needed based on relatedEntityId
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('حدث خطأ أثناء تحميل الإشعارات'));
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'maintenance':
        return Icons.construction;
      case 'billing':
        return Icons.receipt;
      case 'system':
      default:
        return Icons.notifications;
    }
  }

  void _showPreferencesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: BlocProvider.of<NotificationBloc>(context),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.preferences != null) {
                  final prefs = state.preferences!;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'إعدادات الإشعارات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: const Text('إشعارات البريد الإلكتروني'),
                        subtitle: const Text(
                          'استلام التحديثات المهمة عبر البريد',
                        ),
                        value: prefs.emailEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          context.read<NotificationBloc>().add(
                            UpdateNotificationPreferences(emailEnabled: value),
                          );
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('إشعارات الهاتف (Push)'),
                        subtitle: const Text(
                          'استلام التنبيهات الفورية على جهازك',
                        ),
                        value: prefs.pushEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          context.read<NotificationBloc>().add(
                            UpdateNotificationPreferences(pushEnabled: value),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }

                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
