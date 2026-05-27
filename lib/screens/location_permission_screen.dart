import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// Location permission screen — pin illustration + Allow / Remind me later.
///
/// Figma reference: frame 115:76 (iPhone 14 & 15 Pro Max - 10)
class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

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
                // Top bar: back arrow + GTG logo
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back arrow (matches Figma Vector node 115:101)
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 28,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const GtgSmallLogo(),
                    ],
                  ),
                ),

                const Spacer(),

                // Location illustration (180×180)
                Image.network(
                  'https://www.figma.com/api/mcp/asset/b4422bb2-3599-4065-8dc3-65a8693dff9e',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.location_on_rounded,
                    size: 120,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // "Allow Location"
                Text(
                  'Allow Location',
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Body text
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'We need your permission to\naccess your location.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Allow button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Allow',
                      onPressed: () {
                        // TODO: Request location permission, then navigate
                        context.go('/home');
                      },
                      trailing: const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.onPrimary, size: 20),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // "Remind me later" link
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Text(
                    'Remind me later',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
