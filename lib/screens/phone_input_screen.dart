import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// Phone number entry screen.
///
/// Figma reference: frame 58:35 (iPhone 14 & 15 Pro Max - 4)
class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _phoneError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Phone number is required';
    // E.164 format: optional + followed by 7-15 digits
    final regex = RegExp(r'^\+?[1-9]\d{6,14}$');
    if (!regex.hasMatch(trimmed.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Enter a valid phone number (e.g. +91 99000 00000)';
    }
    return null;
  }

  Future<void> _onSubmit() async {
    final error = _validatePhone(_controller.text);
    if (error != null) {
      setState(() => _phoneError = error);
      return;
    }
    setState(() => _phoneError = null);
    final auth = context.read<AuthProvider>();
    auth.setPhoneNumber(_controller.text.trim());
    final success = await auth.submitPhoneNumber();
    if (success && mounted) {
      context.go('/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _ResponsiveColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Image.network(
                        'https://www.figma.com/api/mcp/asset/f6a934d5-1a15-43f6-a39e-3f347ecda87d',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, _, _) => const Icon(
                            Icons.arrow_back_rounded, size: 24),
                      ),
                    ),
                    const Spacer(),
                    const GtgSmallLogo(),
                  ],
                ),
              ),

              // Illustration
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Image.network(
                    'https://www.figma.com/api/mcp/asset/014949cc-534f-4a70-9f46-cd98a89d907f',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.smartphone_rounded,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Center(
                child: Text('OTP Verification', style: AppTextStyles.headingMedium),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      // Phone field
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '+91 99000 00000',
                          hintStyle: AppTextStyles.hintText,
                          filled: true,
                          fillColor: AppColors.surface,
                          errorText: _phoneError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.input),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onChanged: (_) {
                          if (_phoneError != null) {
                            setState(() => _phoneError = null);
                          }
                        },
                        onSubmitted: (_) => _onSubmit(),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Helper text
                      Text(
                        'By entering a valid phone number,\nyou are Good To Go.',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),

                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          auth.errorMessage!,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: AppPrimaryButton(
                          label: 'Submit',
                          isLoading: auth.isLoading,
                          onPressed: _onSubmit,
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              color: AppColors.onPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────

/// Centres and constrains the content to 430 px on wide screens (web/tablet).
class _ResponsiveColumn extends StatelessWidget {
  final Widget child;
  const _ResponsiveColumn({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    );
  }
}
