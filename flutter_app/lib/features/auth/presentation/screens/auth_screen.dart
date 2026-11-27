import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/customer_auth_provider.dart';

enum AuthMode { login, register, verify }

class AuthScreen extends ConsumerStatefulWidget {
  final AuthMode initialMode;

  const AuthScreen({
    super.key,
    this.initialMode = AuthMode.login,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late AuthMode _mode;

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _showLoginPassword = false;

  // Register controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerAddressController = TextEditingController();
  bool _showRegisterPassword = false;

  // Verify controllers (6 digits)
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerPhoneController.dispose();
    _registerAddressController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _switchMode(AuthMode newMode) {
    setState(() {
      _mode = newMode;
    });
    ref.read(customerAuthProvider.notifier).clearMessages();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់ឱ្យបានត្រឹមត្រូវ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(customerAuthProvider.notifier)
        .login(email, password);

    if (mounted) {
      final authState = ref.read(customerAuthProvider);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 ចូលប្រើប្រាស់ដោយជោគជ័យ!'),
            backgroundColor: Color(0xFF15803D),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      } else if (authState.unverifiedEmail != null) {
        setState(() {
          _mode = AuthMode.verify;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text.trim();
    final phone = _registerPhoneController.text.trim();
    final address = _registerAddressController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបំពេញឈ្មោះ អ៊ីមែល និងពាក្យសម្ងាត់ឱ្យបានពេញលេញ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ref
        .read(customerAuthProvider.notifier)
        .register(
          name: name,
          email: email,
          password: password,
          phone: phone,
          address: address,
        );

    if (mounted && success) {
      setState(() {
        _mode = AuthMode.verify;
      });
    }
  }

  Future<void> _handleVerify() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបញ្ចូលលេខកូដសម្ងាត់ ៦ ខ្ទង់ឱ្យបានគ្រប់ចំនួន'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final email = ref.read(customerAuthProvider).unverifiedEmail ??
        _registerEmailController.text.trim();

    final success = await ref
        .read(customerAuthProvider.notifier)
        .verifyCode(email, code);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 គណនីរបស់អ្នកត្រូវបានផ្ទៀងផ្ទាត់ដោយជោគជ័យ!'),
          backgroundColor: Color(0xFF15803D),
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    }
  }

  void _fillDevCode(String code) {
    final digits = code.split('');
    for (int i = 0; i < 6 && i < digits.length; i++) {
      _otpControllers[i].text = digits[i];
    }
    if (_otpFocusNodes[5].canRequestFocus) {
      _otpFocusNodes[5].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(customerAuthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () {
            if (_mode == AuthMode.verify) {
              setState(() {
                _mode = AuthMode.login;
              });
            } else if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryColor, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/phum_yeung_logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primaryColor,
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ភោជនីយដ្ឋាន ភូមិយើង',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Title & Subtitle
                      _buildHeaderTitle(authState),

                      const SizedBox(height: 18),

                      // Mode Segmented Pill Switcher (Login / Register)
                      if (_mode != AuthMode.verify) _buildSegmentedPills(),

                      const SizedBox(height: 16),

                      // Status Alert Banners
                      if (authState.errorMessage != null)
                        _buildAlertBanner(
                          authState.errorMessage!,
                          isError: true,
                        ),
                      if (authState.successMessage != null)
                        _buildAlertBanner(
                          authState.successMessage!,
                          isError: false,
                        ),

                      // Dev Code Auto-Fill Card (Matching Web Dev Mode Hint)
                      if (_mode == AuthMode.verify && authState.devCode != null)
                        _buildDevCodeCard(authState.devCode!),

                      const SizedBox(height: 8),

                      // Form Body (Login, Register, or Verify)
                      if (_mode == AuthMode.login)
                        _buildLoginForm(authState)
                      else if (_mode == AuthMode.register)
                        _buildRegisterForm(authState)
                      else if (_mode == AuthMode.verify)
                        _buildVerifyForm(authState),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(CustomerAuthState state) {
    String title = '';
    String subtitle = '';

    switch (_mode) {
      case AuthMode.login:
        title = 'ចូលគណនី';
        subtitle = 'សូមបញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់របស់អ្នកដើម្បីចូលប្រើប្រាស់';
        break;
      case AuthMode.register:
        title = 'ចុះឈ្មោះគណនីថ្មី';
        subtitle = 'បង្កើតគណនីជាមួយយើងដើម្បីទទួលបានការផ្ដល់ជូនពិសេស';
        break;
      case AuthMode.verify:
        final email = state.unverifiedEmail ?? _registerEmailController.text;
        title = 'ផ្ទៀងផ្ទាត់លេខកូដ';
        subtitle = 'សូមបញ្ចូលលេខកូដសម្ងាត់ ៦ ខ្ទង់ដែលបានផ្ញើទៅកាន់ $email';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppTheme.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedPills() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _switchMode(AuthMode.login),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mode == AuthMode.login
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _mode == AuthMode.login
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.vpn_key_outlined,
                      size: 16,
                      color: _mode == AuthMode.login
                          ? Colors.white
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ចូលគណនី',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _mode == AuthMode.login
                            ? Colors.white
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _switchMode(AuthMode.register),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _mode == AuthMode.register
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _mode == AuthMode.register
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: _mode == AuthMode.register
                          ? Colors.white
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ចុះឈ្មោះ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _mode == AuthMode.register
                            ? Colors.white
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 18,
            color: isError ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: isError ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevCodeCard(String devCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        children: [
          const Text(
            '⚠️ ការផ្ញើសំបុត្រពិតប្រាកដ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dev Code: $devCode',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _fillDevCode(devCode),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    '(បំពេញស្វ័យប្រវត្តិ)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1. Login Form
  Widget _buildLoginForm(CustomerAuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _loginEmailController,
          label: 'អ៊ីមែល',
          hintText: 'example@gmail.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _loginPasswordController,
          label: 'ពាក្យសម្ងាត់',
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscureText: !_showLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showLoginPassword ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: AppTheme.textMuted,
            ),
            onPressed: () {
              setState(() {
                _showLoginPassword = !_showLoginPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: authState.isLoading ? null : _handleLogin,
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'ចូលប្រើប្រាស់',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'មិនទាន់មានគណនីមែនទេ? ',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
            ),
            InkWell(
              onTap: () => _switchMode(AuthMode.register),
              child: const Text(
                'ចុះឈ្មោះឥឡូវនេះ',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Register Form
  Widget _buildRegisterForm(CustomerAuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: _registerNameController,
          label: 'ឈ្មោះពេញ',
          hintText: 'សុខ សាន',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerEmailController,
          label: 'អ៊ីមែល',
          hintText: 'example@gmail.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerPasswordController,
          label: 'ពាក្យសម្ងាត់',
          hintText: 'យ៉ាងតិច ៦ តួអក្សរ',
          icon: Icons.lock_outline,
          obscureText: !_showRegisterPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _showRegisterPassword ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: AppTheme.textMuted,
            ),
            onPressed: () {
              setState(() {
                _showRegisterPassword = !_showRegisterPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerPhoneController,
          label: 'លេខទូរស័ព្ទ',
          hintText: '012 345 678',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _registerAddressController,
          label: 'អាសយដ្ឋានដឹកជញ្ជូន',
          hintText: 'ផ្ទះលេខ..., ផ្លូវ..., សង្កាត់..., រាជធានីភ្នំពេញ',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: authState.isLoading ? null : _handleRegister,
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'ចុះឈ្មោះឥឡូវនេះ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'មានគណនីរួចហើយ? ',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
            ),
            InkWell(
              onTap: () => _switchMode(AuthMode.login),
              child: const Text(
                'ចូលប្រើប្រាស់',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. Verify OTP Form (6 Digits)
  Widget _buildVerifyForm(CustomerAuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 22),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: authState.isLoading ? null : _handleVerify,
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'ផ្ទៀងផ្ទាត់',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'មិនទាន់ទទួលបានលេខកូដ? ',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
            ),
            InkWell(
              onTap: () {
                final email = authState.unverifiedEmail ?? _registerEmailController.text;
                if (email.isNotEmpty) {
                  ref.read(customerAuthProvider.notifier).resendCode(email);
                }
              },
              child: const Text(
                'ផ្ញើឡើងវិញ',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _switchMode(AuthMode.login),
            child: const Text(
              '← ត្រឡប់ទៅចូលគណនី',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
