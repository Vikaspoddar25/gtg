import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';

// ── Figma asset URLs (frame 369:968) ──────────────────────────────────────
const _kRoadIllustration =
    'https://www.figma.com/api/mcp/asset/8f6f7a9a-6975-437e-ab7b-78ab2bca2506';
// Back circle asset from Figma (unused — using Material icon)
// 'https://www.figma.com/api/mcp/asset/7760c56c-b52d-4ff4-9333-295a0645f043'

/// Search / Find screen — select range in kilometres with a slider.
///
/// Figma reference: frame 369:968 (iPhone 14 & 15 Pro Max - 31)
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  double _rangeKm = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              // ── Gradient background ──
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFCE3131),
                        Color(0xFFE8A56E),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Main content ──
              Column(
                children: [
                  // Top bar
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          // Back button (white circle)
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Title
                          Text(
                            "Let's Good To Go!",
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── White card ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(64),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(1, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.lg),

                            // Road illustration
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl),
                              child: Image.network(
                                _kRoadIllustration,
                                height: 198,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.route_rounded,
                                  size: 100,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // "Select range in kilometres"
                            Text(
                              'Select range in kilometeres',
                              style: AppTextStyles.headingMedium,
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Range label
                            Text(
                              '${_rangeKm.round()}Km',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),

                            // Slider
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl),
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: const Color(0xFFFFEDED),
                                  thumbColor: const Color(0xFF710000),
                                  thumbShape: const RoundedRectSliderThumbShape(
                                      enabledThumbRadius: 22),
                                  trackHeight: 44,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  trackShape: const RoundedRectSliderTrackShape(),
                                ),
                                child: Slider(
                                  value: _rangeKm,
                                  min: 1,
                                  max: 50,
                                  onChanged: (v) =>
                                      setState(() => _rangeKm = v),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // Find button (gradient, rounded bottom)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm),
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to search results
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 77,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFDD4D4D),
                                        Color(0xFFCE3131),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(52),
                                      bottomRight: Radius.circular(52),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Find',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Progress dots (5 bars)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Container(
                        width: 62,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom rounded rectangle thumb for the range slider.
class RoundedRectSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;

  const RoundedRectSliderThumbShape({required this.enabledThumbRadius});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(enabledThumbRadius * 2, enabledThumbRadius * 2.8);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center,
          width: enabledThumbRadius * 2,
          height: enabledThumbRadius * 2.8),
      const Radius.circular(8),
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC33C3C), Color(0xFF710000)],
      ).createShader(rect.outerRect);
    canvas.drawRRect(rect, paint);
  }
}
