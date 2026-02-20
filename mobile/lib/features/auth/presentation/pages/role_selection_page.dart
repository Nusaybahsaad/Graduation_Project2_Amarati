import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'register_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole;

  final List<Map<String, dynamic>> roles = [
    {
      'id': 'owner',
      'title': 'مالك',
      'subtitle': 'إدارة الشقة ، متابعة الصيانة ، والإشراف على كل الوحدات',
      'icon': Icons.home_work_rounded,
    },
    {
      'id': 'tenant',
      'title': 'مستأجر',
      'subtitle': 'إرسال طلبات الصيانة، استلام التنبيهات ومتابعة الخدمات',
      'icon': Icons.person_pin_rounded,
    },
    {
      'id': 'supervisor',
      'title': 'مشرف',
      'subtitle': 'ترتيب المهام اليومية، متابعة العمال واعتماد الطلبات',
      'icon': Icons.manage_accounts_rounded,
    },
    {
      'id': 'provider',
      'title': 'شركة صيانة',
      'subtitle': 'استلام البلاغات، تنفيذ الطلبات، وتحديث حالة الأعمال',
      'icon': Icons.engineering_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              'اختر نوع حسابك',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'حتى نوفر لك تجربة مخصصة\nلتناسب دورك داخل العمارة',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: roles.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final role = roles[index];
                  final isSelected = selectedRole == role['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = role['id'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  role['subtitle'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            role['icon'],
                            size: 32,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: selectedRole == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              RegisterPage(role: selectedRole!),
                        ),
                      );
                    },
              child: const Text('التالي'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
