import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';

/// Splash screen — deep red with the GTG logo and "Welcome Back!" tagline.
/// Auto-navigates to /signin after a short delay.
///
/// Figma reference: frame 87:26 (iPhone 14 & 15 Pro Max - 6)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GTG logo (289×272 from Figma)
              Image.asset(
                'assets/images/GTG Logo.png',
                width: 220,
                height: 207,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 29,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
