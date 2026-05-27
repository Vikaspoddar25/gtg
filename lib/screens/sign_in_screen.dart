import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// Sign In screen with email/password, social sign-in, and link to Sign Up.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (ok && mounted) context.go('/home');
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

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 12),
            TextField(
              controller: resetController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'example@gmail.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = resetController.text.trim();
              if (email.isEmpty) return;
              try {
                await context.read<AuthProvider>().sendPasswordReset(email);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Password reset email sent!')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
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

              // Top-right logo
              Align(
                alignment: Alignment.centerRight,
                child: const GtgSmallLogo(
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Shield illustration
              Center(
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Center(
                child: Text('Sign In', style: AppTextStyles.headingMedium),
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

              const SizedBox(height: AppSpacing.xl),

              // E-mail label
              Text('E-mail', style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.xs),

              // E-mail field
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

              // Password label
              Text('Password',
                  style: AppTextStyles.body.copyWith(fontSize: 13)),
              const SizedBox(height: AppSpacing.xs),

              // Password field
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

              // Forgot password
              Center(
                child: GestureDetector(
                  onTap: () => _showForgotPasswordDialog(),
                  child: Text(
                    'Forgot your password?',
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

              // Sign in with Apple
              _SocialButton(
                label: 'Sign in with Apple',
                icon: Icons.apple,
                iconColor: Colors.black,
                onTap: _onAppleSignIn,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Sign in with Google
              _SocialButton(
                label: 'Sign in with Google',
                iconWidget: Text('G',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.red)),
                backgroundColor: const Color(0xFFE8F0FE),
                onTap: _onGoogleSignIn,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Sign Up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('New to GoodToGo? ', style: AppTextStyles.body),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: Text(
                      'Sign Up',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
