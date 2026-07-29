import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/models/route.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/providers/gtg_flow_provider.dart';
import 'package:gtg/providers/route_provider.dart';
import 'package:gtg/providers/venue_provider.dart';
import 'package:gtg/theme/app_colors.dart';

/// Brief transition screen shown while the GTG flow's answers are turned
/// into a real route (filtering venues, creating the draft route doc).
/// Navigates to `/routes` once [RouteProvider.generateRoute] resolves.
class GeneratingRouteScreen extends StatefulWidget {
  const GeneratingRouteScreen({super.key});

  @override
  State<GeneratingRouteScreen> createState() => _GeneratingRouteScreenState();
}

class _GeneratingRouteScreenState extends State<GeneratingRouteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    final flow = context.read<GtgFlowProvider>();
    final auth = context.read<AuthProvider>();
    final venueProvider = context.read<VenueProvider>();
    final routeProvider = context.read<RouteProvider>();

    if (venueProvider.venues.isEmpty) {
      await venueProvider.loadVenues(city: 'New Delhi');
    }

    final preferences = RoutePreferences(
      numberOfFriends: flow.numberOfFriends,
      budgetPerPerson: flow.budgetPerPerson,
      selectedModes: flow.selectedModes.toList(),
      hoursToSpend: flow.hoursToSpend.toDouble(),
      rangeKm: flow.rangeKm,
    );

    await routeProvider.generateRoute(
      userId: auth.user?.uid ?? '',
      preferences: preferences,
      availableVenues: venueProvider.venues,
    );

    flow.reset();
    if (mounted) context.go('/routes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/GTG Logo.png',
                width: 96,
                height: 68,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              const _PulsingRouteIcon(),
              const SizedBox(height: 32),
              const Text(
                'Generating your route...',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingRouteIcon extends StatefulWidget {
  const _PulsingRouteIcon();

  @override
  State<_PulsingRouteIcon> createState() => _PulsingRouteIconState();
}

class _PulsingRouteIconState extends State<_PulsingRouteIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: const Icon(
        Icons.location_searching_rounded,
        size: 88,
        color: AppColors.primary,
      ),
    );
  }
}
