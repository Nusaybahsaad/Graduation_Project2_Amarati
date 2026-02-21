import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _propertyIdController = TextEditingController();

  String _selectedCategory = 'Plumbing';
  String _selectedPriority = 'MEDIUM';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'Plumbing', 'label': 'سباكة', 'icon': Icons.plumbing},
    {
      'value': 'Electrical',
      'label': 'كهرباء',
      'icon': Icons.electrical_services,
    },
    {'value': 'HVAC', 'label': 'تكييف', 'icon': Icons.ac_unit},
    {'value': 'Cleaning', 'label': 'تنظيف', 'icon': Icons.cleaning_services},
    {'value': 'Painting', 'label': 'دهان', 'icon': Icons.format_paint},
    {'value': 'General', 'label': 'عام', 'icon': Icons.build},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'LOW', 'label': 'منخفض', 'color': AppColors.success},
    {'value': 'MEDIUM', 'label': 'متوسط', 'color': AppColors.warning},
    {'value': 'HIGH', 'label': 'مرتفع', 'color': Colors.deepOrange},
    {'value': 'EMERGENCY', 'label': 'طارئ', 'color': AppColors.error},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _propertyIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    context.read<MaintenanceBloc>().add(
      CreateMaintenanceRequest(
        propertyId: _propertyIdController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MaintenanceBloc, MaintenanceState>(
      listener: (context, state) {
        if (state is MaintenanceCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء طلب الصيانة بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is MaintenanceError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'طلب صيانة جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property ID
                const Text(
                  'معرف العقار',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _propertyIdController,
                  decoration: _inputDecoration(
                    'أدخل معرف العقار',
                    Icons.apartment,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'عنوان الطلب',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    'مثال: تسرب مياه في المطبخ',
                    Icons.title,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'وصف المشكلة',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    'اشرح المشكلة بالتفصيل...',
                    Icons.description,
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 24),

                // Category Selector
                const Text(
                  'التصنيف',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['value'];
                    return ChoiceChip(
                      avatar: Icon(
                        cat['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      label: Text(cat['label'] as String),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (selected) {
                        if (selected)
                          setState(
                            () => _selectedCategory = cat['value'] as String,
                          );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Priority Selector
                const Text(
                  'الأولوية',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _priorities.map((p) {
                    final isSelected = _selectedPriority == p['value'];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            p['label'] as String,
                            style: TextStyle(fontSize: 12),
                          ),
                          selected: isSelected,
                          selectedColor: (p['color'] as Color).withOpacity(0.2),
                          backgroundColor: AppColors.surfaceVariant,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? p['color'] as Color
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? p['color'] as Color
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          onSelected: (selected) {
                            if (selected)
                              setState(
                                () => _selectedPriority = p['value'] as String,
                              );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'إرسال الطلب',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
