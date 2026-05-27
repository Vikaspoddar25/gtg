import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// Verified / authentication success screen.
///
/// Figma reference: frame 87:104 (iPhone 14 & 15 Pro Max - 7)
class VerifiedScreen extends StatelessWidget {
  const VerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                // GTG logo — top right
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: const GtgSmallLogo(),
                  ),
                ),

                const Spacer(),

                // Shield illustration
                Image.network(
                  'https://www.figma.com/api/mcp/asset/a01c753f-52ae-44a9-b480-6c169dc31adc',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.verified_user_rounded,
                    size: 120,
                    color: AppColors.success,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // "Verified!" — green
                Text('Verified!', style: AppTextStyles.headingSuccess),

                const SizedBox(height: AppSpacing.md),

                // Body text
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Congratulations! You have been\nsuccessfully authenticated.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // Continue button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Continue',
                      onPressed: () => context.go('/home'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.onPrimary, size: 18),
                    ),
                  ),
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
