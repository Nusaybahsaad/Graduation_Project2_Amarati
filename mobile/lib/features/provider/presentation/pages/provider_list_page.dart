import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/provider_model.dart';
import '../../domain/repositories/provider_repository.dart';

class ProviderListPage extends StatefulWidget {
  const ProviderListPage({super.key});

  @override
  State<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends State<ProviderListPage> {
  List<ProviderModel> _providers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'value': null, 'label': 'الكل', 'icon': Icons.apps},
    {'value': 'Plumbing', 'label': 'سباكة', 'icon': Icons.plumbing},
    {
      'value': 'Electrical',
      'label': 'كهرباء',
      'icon': Icons.electrical_services,
    },
    {'value': 'HVAC', 'label': 'تكييف', 'icon': Icons.ac_unit},
    {'value': 'Cleaning', 'label': 'تنظيف', 'icon': Icons.cleaning_services},
    {'value': 'Painting', 'label': 'دهان', 'icon': Icons.format_paint},
  ];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = sl<ProviderRepository>();
    final result = await repo.getProviders(category: _selectedCategory);

    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      }),
      (providers) => setState(() {
        _providers = providers;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'مقدمو الخدمات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['value'];
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      cat['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    label: Text(cat['label'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(
                        () => _selectedCategory = cat['value'] as String?,
                      );
                      _loadProviders();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Provider List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProviders,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : _providers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.handyman_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا يوجد مقدمو خدمات',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProviders,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _providers.length,
                      itemBuilder: (context, index) =>
                          _ProviderCard(provider: _providers[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.handyman,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.companyName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (provider.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: AppColors.info,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.serviceCategoryLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 14),

            // Stats Row
            Row(
              children: [
                // Rating
                _StatBadge(
                  icon: Icons.star,
                  iconColor: AppColors.warning,
                  value: provider.rating.toStringAsFixed(1),
                ),
                const SizedBox(width: 16),
                // Jobs
                _StatBadge(
                  icon: Icons.work_outline,
                  iconColor: AppColors.info,
                  value: '${provider.totalJobs} مهمة',
                ),
                const SizedBox(width: 16),
                // City
                _StatBadge(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.success,
                  value: provider.city,
                ),
                const Spacer(),
                // Rate
                if (provider.hourlyRate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.hourlyRate!.toStringAsFixed(0)} د.أ/ساعة',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),

            if (provider.description != null &&
                provider.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                provider.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
