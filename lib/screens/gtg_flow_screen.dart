import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/providers/gtg_flow_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/app_primary_button.dart';

/// Orchestrates the 5-step "Let's Good To Go" flow.
class GtgFlowScreen extends StatefulWidget {
  const GtgFlowScreen({super.key});

  @override
  State<GtgFlowScreen> createState() => _GtgFlowScreenState();
}

class _GtgFlowScreenState extends State<GtgFlowScreen> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    final flow = context.read<GtgFlowProvider>();
    if (flow.currentStep < 4) {
      flow.setStep(flow.currentStep + 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final step — Find → generate the real route, then view it.
      context.go('/generating-route');
    }
  }

  void _back() {
    final flow = context.read<GtgFlowProvider>();
    if (flow.currentStep > 0) {
      flow.setStep(flow.currentStep - 1);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<GtgFlowProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFFE0B2), Color(0xFFFFAB91)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top bar: back/close + title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _back,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              flow.currentStep == 0
                                  ? Icons.close
                                  : Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Let's Good To Go!",
                          style: AppTextStyles.headingMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Step number
                  Text(
                    '${flow.currentStep + 1}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _Step1Friends(onContinue: _next),
                        _Step2Budget(onContinue: _next),
                        _Step3Modes(onContinue: _next),
                        _Step4Hours(onContinue: _next),
                        _Step5Range(onFind: _next),
                      ],
                    ),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared step card wrapper ────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final List<Widget> children;
  const _StepCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.panel),
          boxShadow: const [AppShadows.card],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

// ── GTG logo for inside cards ───────────────────────────────────────────────
class _CardLogo extends StatelessWidget {
  const _CardLogo();
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/GTG Logo.png',
      width: 40,
      height: 40,
      fit: BoxFit.contain,
    );
  }
}

// ── Number picker row (used in steps 1 & 4) ────────────────────────────────
class _NumberPicker extends StatelessWidget {
  final List<int> options;
  final int selected;
  final ValueChanged<int> onChanged;
  const _NumberPicker({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((n) {
        final isSelected = n == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onChanged(n),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── STEP 1: Number of friends ───────────────────────────────────────────────
class _Step1Friends extends StatelessWidget {
  final VoidCallback onContinue;
  const _Step1Friends({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<GtgFlowProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: _StepCard(
        children: [
          const _CardLogo(),
          const SizedBox(height: 8),
          // Friends illustration placeholder
          Icon(Icons.people_alt_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Mention number of friends',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          // Input box display
          Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${flow.numberOfFriends}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _NumberPicker(
            options: const [2, 4, 6, 8],
            selected: flow.numberOfFriends,
            onChanged: flow.setNumberOfFriends,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Continue',
            onPressed: onContinue,
            trailing: const Icon(Icons.arrow_forward,
                color: AppColors.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── STEP 2: Budget per person ───────────────────────────────────────────────
class _Step2Budget extends StatelessWidget {
  final VoidCallback onContinue;
  const _Step2Budget({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<GtgFlowProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: _StepCard(
        children: [
          const _CardLogo(),
          const SizedBox(height: 8),
          // Money illustration placeholder
          Icon(Icons.payments_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Budget per person',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          // Budget input display
          Container(
            width: 120,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
            alignment: Alignment.center,
            child: Text(
              '₹${flow.budgetPerPerson}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Budget quick picks
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [250, 500, 1000, 10000].map((amount) {
              final isSelected = amount == flow.budgetPerPerson;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => flow.setBudget(amount),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    child: Text(
                      '₹$amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Continue',
            onPressed: onContinue,
            trailing: const Icon(Icons.arrow_forward,
                color: AppColors.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── STEP 3: Select modes ────────────────────────────────────────────────────
class _Step3Modes extends StatelessWidget {
  final VoidCallback onContinue;
  const _Step3Modes({required this.onContinue});

  static const _modes = [
    _ModeData(
      name: 'Foodie',
      subtitle: '"Foodie Frenzy: Tasting Our Way Through Town"',
      icon: Icons.restaurant,
    ),
    _ModeData(
      name: 'Explorer',
      subtitle: '"Monumental Moments: Exploring Our Roots"',
      icon: Icons.explore,
    ),
    _ModeData(
      name: 'Chillaxed',
      subtitle: '"Chill Squad Hangs: Casual Vibes Only"',
      icon: Icons.local_bar,
    ),
    _ModeData(
      name: 'Adventurous',
      subtitle: '"Thrills & Chills: Adventure Awaits!"',
      icon: Icons.terrain,
    ),
    _ModeData(
      name: 'Unseen Events',
      subtitle: '"FOMO-Free Zone: Exclusive Experiences Only"',
      icon: Icons.event,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<GtgFlowProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: _StepCard(
        children: [
          const _CardLogo(),
          const SizedBox(height: 8),
          Text(
            'Select modes',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          ..._modes.map((mode) {
            final isSelected = flow.selectedModes.contains(mode.name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => flow.toggleMode(mode.name),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(mode.icon,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            mode.subtitle,
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          AppPrimaryButton(
            label: 'Continue',
            onPressed: onContinue,
            trailing: const Icon(Icons.arrow_forward,
                color: AppColors.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ModeData {
  final String name;
  final String subtitle;
  final IconData icon;
  const _ModeData({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

// ── STEP 4: Hours to spend ──────────────────────────────────────────────────
class _Step4Hours extends StatelessWidget {
  final VoidCallback onContinue;
  const _Step4Hours({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<GtgFlowProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: _StepCard(
        children: [
          const _CardLogo(),
          const SizedBox(height: 8),
          // Clock illustration placeholder
          Icon(Icons.access_time_filled, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Mention number of hours\nto spend',
            textAlign: TextAlign.center,
            style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${flow.hoursToSpend}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _NumberPicker(
            options: const [2, 4, 6, 8],
            selected: flow.hoursToSpend,
            onChanged: flow.setHours,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Continue',
            onPressed: onContinue,
            trailing: const Icon(Icons.arrow_forward,
                color: AppColors.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── STEP 5: Range in kilometers ─────────────────────────────────────────────
const _kRoadIllustration =
    'https://www.figma.com/api/mcp/asset/8f6f7a9a-6975-437e-ab7b-78ab2bca2506';

class _Step5Range extends StatelessWidget {
  final VoidCallback onFind;
  const _Step5Range({required this.onFind});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<GtgFlowProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: _StepCard(
        children: [
          const _CardLogo(),
          const SizedBox(height: 8),
          // Road illustration
          Image.network(
            _kRoadIllustration,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(Icons.route, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Select range in kilometeres',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Text(
            '${flow.rangeKm.toStringAsFixed(0)}Km',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primaryLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
              ),
            ),
            child: Slider(
              value: flow.rangeKm,
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: flow.setRange,
            ),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Find',
            onPressed: onFind,
            trailing: const Icon(Icons.arrow_forward,
                color: AppColors.onPrimary, size: 20),
          ),
        ],
      ),
    );
  }
}
