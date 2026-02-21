import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import 'chat_room_page.dart';

class CommunityHubPage extends StatefulWidget {
  const CommunityHubPage({super.key});

  @override
  State<CommunityHubPage> createState() => _CommunityHubPageState();
}

class _CommunityHubPageState extends State<CommunityHubPage> {
  String? _propertyId;

  @override
  void initState() {
    super.initState();
    // Assuming user's property ID is fetched from auth state context
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Simplification: using a static property OR picking first one if list exists
      // For this MVP, if tenant belongs to property, logic needs exact property ID
      // If we don't have it directly in user model, maybe user is passed or default selected.
      // E.g:
      // _propertyId = authState.user.activePropertyId;
      // We will try to get it from API or pass it explicitly. For now, assuming propertyId is passed somehow.
      // If we don't have it, we just display empty state.
    }
  }

  void _loadData(String propertyId) {
    context.read<CommunityBloc>().add(FetchAnnouncementsEvent(propertyId));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, dynamic>((bloc) {
      if (bloc.state is AuthAuthenticated) {
        return (bloc.state as AuthAuthenticated).user;
      }
      return null;
    });

    // In a real flow, property selection dropdown or active property is passed to this screen.
    // If the user hasn't selected a property, show a placeholder.
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'المجتمع',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'الإعلانات'),
              Tab(text: 'المجموعات'),
              Tab(text: 'التصويتات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnnouncementsTab(),
            _buildChatRoomsTab(),
            _buildPollsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is AnnouncementsLoaded) {
          final items = state.announcements;
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد إعلانات',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final ann = items[index];
              return Card(
                color: AppColors.surface,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ann.title,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('MM/dd').format(ann.createdAt),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.textHint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ann.content,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'قم بتحديث الصفحة لمعرفة الإعلانات',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              TextButton(
                onPressed: () {
                  // Add propertyId when available
                },
                child: const Text(
                  'تحديث',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatRoomsTab() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is RoomsLoaded) {
          final items = state.rooms;
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد مجموعات محادثة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final room = items[index];
              return Card(
                color: AppColors.surface,
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(room: room),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(Icons.group, color: AppColors.primary),
                  ),
                  title: Text(
                    room.name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    room.roomType == 'MAINTENANCE'
                        ? 'مجموعة صيانة'
                        : 'مجموعة عامة',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: Text(
            'اختر عقار لتحميل المجموعات',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        );
      },
    );
  }

  Widget _buildPollsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_vote,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'ميزة التصويتات قريباً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
