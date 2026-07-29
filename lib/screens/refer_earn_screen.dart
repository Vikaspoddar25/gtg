import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';

/// Refer & Earn screen — shows the user's referral code and lets them
/// share it via WhatsApp or copy it to the clipboard.
class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral code copied!')),
    );
  }

  Future<void> _shareViaWhatsApp(String code) async {
    final message = Uri.encodeComponent(
      "Join me on GTG! Use my referral code $code when you sign up and we both earn GTG coins. 🎉",
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final code = user?.referralCode ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            children: [
              // App bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/settings');
                          }
                        },
                        child: const Icon(Icons.chevron_left, size: 32),
                      ),
                      const Expanded(
                        child: Text(
                          'Refer and Earn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF9E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.card_giftcard_rounded,
                            size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Invite friends, earn GTG coins',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share your referral code — when a friend signs up with it, you both earn GTG coins.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Referral code card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                code.isEmpty ? '—' : code,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 3,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: code.isEmpty
                                  ? null
                                  : () => _copyCode(context, code),
                              child: const Icon(Icons.copy_rounded,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      AppPrimaryButton(
                        label: 'Share via WhatsApp',
                        onPressed:
                            code.isEmpty ? null : () => _shareViaWhatsApp(code),
                        trailing:
                            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
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
