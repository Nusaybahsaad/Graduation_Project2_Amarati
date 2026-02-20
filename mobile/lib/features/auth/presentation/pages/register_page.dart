import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'إنشاء حساب جديد',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'أنت تسجل كـ ${widget.role == 'owner'
                      ? 'مالك'
                      : widget.role == 'tenant'
                      ? 'مستأجر'
                      : widget.role == 'supervisor'
                      ? 'مشرف'
                      : 'شركة صيانة'}',
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 32),

                // Full Name
                TextFormField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'رقم الجوال',
                    prefixIcon: Icon(Icons.phone_android_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  textAlign: TextAlign.right,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    prefixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Registration logic
                    }
                  },
                  child: const Text('إنشاء الحساب'),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('لديك حساب بالفعل؟'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
