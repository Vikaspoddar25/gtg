import 'package:flutter/material.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// No Internet / Offline screen — illustration + Retry button.
///
/// Figma reference: frame 290:326 (iPhone 14 & 15 Pro Max - 22)
class NoInternetScreen extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetScreen({super.key, this.onRetry});

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

                // Offline illustration (257×193)
                Image.network(
                  'https://www.figma.com/api/mcp/asset/e2dcca47-3b9b-40d3-81e4-2fef00b25328',
                  width: 257,
                  height: 193,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.wifi_off_rounded,
                    size: 120,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // "Looks Like\nYou Are Offline"
                Text(
                  'Looks Like\nYou Are Offline',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Body text
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'No internet connection found. Check\nyour connection or try again.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Retry button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Retry',
                      onPressed: onRetry,
                      trailing: const Icon(Icons.refresh_rounded,
                          color: AppColors.onPrimary, size: 20),
                    ),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
