import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

class AdminLoginDialog extends ConsumerStatefulWidget {
  const AdminLoginDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AdminLoginDialog(),
    );
  }

  @override
  ConsumerState<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends ConsumerState<AdminLoginDialog> {
  final _emailController = TextEditingController(text: 'admin@phumyeung.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមបញ្ចូលអុីមែល និងពាក្យសម្ងាត់')),
      );
      return;
    }

    final success = await ref.read(adminProvider.notifier).login(email, pass);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      context.push('/admin/dashboard');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 បានចូលកាន់ផ្ទាំងគ្រប់គ្រង Admin ដោយជោគជ័យ!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else {
      final err = ref.read(adminProvider).errorMessage ?? 'ចូលមិនជោគជ័យទេ';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryColor, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/phum_yeung_logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primaryColor,
                    child: const Icon(Icons.shield, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'ចូលផ្ទាំងគ្រប់គ្រងហាង',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Phum Yeung Restaurant - Admin Portal',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'អុីមែល',
                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'ពាក្យសម្ងាត់',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Fill Button
            InkWell(
              onTap: () {
                _emailController.text = 'admin@phumyeung.com';
                _passwordController.text = 'admin123';
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondarySubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.secondaryLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bolt, size: 16, color: AppTheme.secondaryDark),
                    SizedBox(width: 6),
                    Text(
                      'គណនីតេស្ត: admin@phumyeung.com / admin123',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondaryDark),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: adminState.isLoading ? null : _handleLogin,
                child: adminState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'ចូលគ្រប់គ្រង',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('បោះបង់', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
