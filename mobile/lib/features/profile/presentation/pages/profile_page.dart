import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Prevent back navigation after logout
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: const SizedBox.shrink(), // No back button needed on root tab
          actions: [
            // Placeholder space to match exact Figma alignment
            const SizedBox(width: 24),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String name = 'محمد أحمد';
              String email = 'mohammed@gmail.com';

              if (state is AuthAuthenticated) {
                name = state.user.fullName;
                email = state.user.email;
              }

              return Column(
                children: [
                  const SizedBox(height: 16),
                  // User Profile Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary.withOpacity(0.8),
                        child: const Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Menu Items
                  _buildMenuItem(
                    context,
                    'اللغة',
                    Icons.language_outlined,
                    trailing: _buildLangToggle(),
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    'إعدادات الحساب',
                    Icons.settings_outlined,
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    'الاشعارات',
                    Icons.notifications_none_outlined,
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    'المساعدة والدعم',
                    Icons.help_outline_rounded,
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(context, 'حول', Icons.info_outline_rounded),
                  const Divider(height: 1),
                  _buildMenuItem(
                    context,
                    'الأسئلة الشائعة',
                    Icons.quickreply_outlined,
                  ),
                  const Divider(height: 1),

                  const SizedBox(height: 16),

                  // Privacy Toggles
                  _buildToggleItem('إظهار الملف الشخصي للسكان', true),
                  _buildToggleItem('إظهار رقم الهاتف', true),
                  _buildToggleItem('إظهار البريد الالكتروني', false),

                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          if (trailing != null) const SizedBox(width: 16),
          Icon(icon, color: AppColors.textPrimary),
        ],
      ),
      leading: trailing == null
          ? const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey)
          : null,
      onTap: () {},
    );
  }

  Widget _buildToggleItem(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: AppColors.primary,
          ),
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Icon(
                Icons.visibility_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'EN',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: const Text(
              'AR',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
