import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';

/// OTP verification screen — 4-box code entry with countdown timer.
///
/// Figma reference: frame 72:150 (iPhone 14 & 15 Pro Max - 5)
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _totalSeconds = 60;

  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _remaining = _totalSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remaining = _totalSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 0) {
        t.cancel();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  String get _timerDisplay {
    final min = (_remaining ~/ 60).toString().padLeft(2, '0');
    final sec = (_remaining % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String get _fullOtp =>
      _controllers.map((c) => c.text).join();

  Future<void> _onVerify() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(_fullOtp);
    if (success && mounted) {
      context.go('/verified');
    }
  }

  Future<void> _onResend() async {
    if (_remaining > 0) return;
    await context.read<AuthProvider>().resendOtp();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
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
                        onTap: () => context.go('/signin'),
                        child: const Icon(Icons.close_rounded, size: 24),
                      ),
                      const Spacer(),
                      const GtgSmallLogo(),
                    ],
                  ),
                ),

                // Illustration
                Center(
                  child: Image.network(
                    'https://www.figma.com/api/mcp/asset/67ba45cf-79d8-4ac7-8529-355a908108af',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.lock_rounded,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Center(
                  child: Text('Verification Code',
                      style: AppTextStyles.headingMedium),
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        // 4 OTP boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (i) => _OtpBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            onChanged: (val) {
                              if (val.isNotEmpty && i < 3) {
                                _focusNodes[i + 1].requestFocus();
                              } else if (val.isEmpty && i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                            },
                          )),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Resend + Timer row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _remaining == 0 ? _onResend : null,
                              child: Text(
                                'Resend SMS',
                                style: AppTextStyles.timerLabel.copyWith(
                                  color: _remaining == 0
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(_timerDisplay,
                                    style: AppTextStyles.timerLabel),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Helper text
                        Text(
                          'We have sent the verification code\non the given phone number.',
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

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          child: AppPrimaryButton(
                            label: 'Verify',
                            isLoading: auth.isLoading,
                            onPressed: _onVerify,
                            trailing: const Icon(Icons.check_circle_outline_rounded,
                                color: AppColors.onPrimary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Edit phone number link
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/signin'),
                    child: Text('Edit phone number?',
                        style: AppTextStyles.linkLabel),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

// ── OTP box widget ─────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 67,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────
