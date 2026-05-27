import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// Sign Up screen with username, email, password, social sign-up, and link to Sign In.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Include an uppercase letter';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Include a lowercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Include a number';
    if (!value.contains(RegExp(r'[!@#\$%\^&\*\.\-_]'))) {
      return 'Include a special character (!@#\$%^&*.-_)';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _usernameController.text.trim(),
    );
    if (ok && mounted) context.go('/phone-input');
  }

  Future<void> _onGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (ok && mounted) context.go('/home');
  }

  Future<void> _onAppleSignIn() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithApple();
    if (ok && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),

              // Top bar: back arrow + logo
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/signin');
                      }
                    },
                    child: const Icon(Icons.arrow_back_rounded, size: 24),
                  ),
                  const Spacer(),
                  const GtgSmallLogo(
                    size: 40,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // ID card illustration
              Center(
                child: Icon(
                  Icons.badge_outlined,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Center(
                child: Text('Sign Up', style: AppTextStyles.headingMedium),
              ),

              // Error message
              if (auth.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    auth.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // Username label + field
              Text('Username',
                  style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _usernameController,
                validator: _validateUsername,
                decoration: const InputDecoration(),
              ),

              const SizedBox(height: AppSpacing.md),

              // E-mail label + field
              Text('E-mail', style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.primary, size: 20),
                  hintText: 'example@gmail.com',
                  hintStyle: AppTextStyles.hintText.copyWith(fontSize: 16),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Create Password label + field
              Text('Create Password',
                  style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Confirm Password label + field
              Text('Confirm Password',
                  style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                validator: _validateConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.primary, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Continue button
              AppPrimaryButton(
                label: 'Continue',
                isLoading: auth.isLoading,
                onPressed: _onContinue,
                trailing: const Icon(Icons.arrow_forward,
                    color: AppColors.onPrimary, size: 20),
              ),

              const SizedBox(height: AppSpacing.md),

              // Already have an account?
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/signin'),
                  child: Text(
                    'Already have an account?',
                    style: AppTextStyles.linkLabel.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Divider with "or"
              _OrDivider(),

              const SizedBox(height: AppSpacing.md),

              // Sign up with Apple
              _SocialButton(
                label: 'Sign up with Apple',
                icon: Icons.apple,
                iconColor: Colors.black,
                onTap: _onAppleSignIn,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Sign up with Google
              _SocialButton(
                label: 'Sign up with Google',
                iconWidget: Text('G',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.red)),
                backgroundColor: const Color(0xFFE8F0FE),
                onTap: _onGoogleSignIn,
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('or',
              style: AppTextStyles.body.copyWith(color: Colors.grey)),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Widget? iconWidget;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.label,
    this.icon,
    this.iconColor,
    this.iconWidget,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ?iconWidget,
            if (icon != null) Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
