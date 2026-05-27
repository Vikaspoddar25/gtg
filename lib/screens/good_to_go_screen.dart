import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';

/// "Now you are Good To Go" screen — red background with GTG logo.
/// Auto-navigates to /home after a short delay.
///
/// Figma reference: frame 92:7 (iPhone 14 & 15 Pro Max - 8)
class GoodToGoScreen extends StatefulWidget {
  const GoodToGoScreen({super.key});

  @override
  State<GoodToGoScreen> createState() => _GoodToGoScreenState();
}

class _GoodToGoScreenState extends State<GoodToGoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GTG logo (289×272)
                Image.asset(
                  'assets/images/GTG Logo.png',
                  width: 220,
                  height: 207,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                // "Now you are Good To Go"!
                Text(
                  '\u201CNow you are\nGood To Go\u201D!',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 29,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
