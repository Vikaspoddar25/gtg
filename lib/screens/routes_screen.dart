import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/models/route.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/providers/route_provider.dart';
import 'package:gtg/providers/venue_provider.dart';
import 'package:gtg/theme/app_colors.dart';

/// Routes screen — shows the generated route of venues after GTG flow.
/// Has 3 states: edit (reorder/delete/refresh), active (show code/cancel),
/// and progress (finished/code revealed). Backed by [RouteProvider.selected].
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

enum RouteScreenState { edit, active, progress }

class _RoutesScreenState extends State<RoutesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<AuthProvider>().user?.uid;
      if (userId != null) {
        context.read<RouteProvider>().startListening(userId);
      }
      if (context.read<VenueProvider>().venues.isEmpty) {
        context.read<VenueProvider>().loadVenues(city: 'New Delhi');
      }
    });
  }

  RouteScreenState _stateFor(GtgRoute route) {
    switch (route.status) {
      case 'active':
        return RouteScreenState.active;
      case 'completed':
        return RouteScreenState.progress;
      default:
        return RouteScreenState.edit;
    }
  }

  Future<void> _onGoodToGo(RouteProvider rp) => rp.activateSelectedRoute();

  Future<void> _onStopHere(RouteProvider rp) async {
    await rp.completeSelectedRoute();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ThankYouDialog(),
    ).then((_) {
      if (mounted) context.go('/home');
    });
  }

  Future<void> _onRegenerate(RouteProvider rp, VenueProvider vp, GtgRoute route) async {
    for (var i = 0; i < route.stops.length; i++) {
      await _refreshStop(rp, vp, i, route);
    }
  }

  Future<void> _moveUp(RouteProvider rp, int index) {
    if (index <= 0) return Future.value();
    return rp.reorderSelectedStop(index, index - 1);
  }

  Future<void> _moveDown(RouteProvider rp, int index, int length) {
    if (index >= length - 1) return Future.value();
    return rp.reorderSelectedStop(index, index + 1);
  }

  Future<void> _removeStop(RouteProvider rp, int index) =>
      rp.removeStopFromSelected(index);

  Future<void> _refreshStop(
      RouteProvider rp, VenueProvider vp, int index, GtgRoute route) async {
    final used = route.stops.map((s) => s.venueId).toSet();
    final candidates = vp.venues.where((v) => !used.contains(v.id)).toList();
    if (candidates.isEmpty) return;
    final v = candidates.first;
    await rp.regenerateStopInSelected(
      index,
      RouteStop(
        venueId: v.id,
        venueName: v.name,
        venueImage: v.imageUrl,
        order: index,
        estimatedDuration: route.stops[index].estimatedDuration,
        lat: v.location?.latitude ?? 0,
        lng: v.location?.longitude ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final venueProvider = context.watch<VenueProvider>();
    final route = routeProvider.selected;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              Column(
                children: [
                  // App bar
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                            child: const Icon(Icons.chevron_left, size: 32),
                          ),
                          const Expanded(
                            child: Text(
                              'Routes',
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

                  if (route == null)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.alt_route_rounded,
                                  size: 64, color: AppColors.primaryLight),
                              const SizedBox(height: 16),
                              const Text(
                                'No route yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Start the GTG flow from Home to generate a route.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () => context.go('/gtg-flow'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Text(
                                    "Let's Good To Go!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Route stops list
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
                        child: Column(
                          children: [
                            for (var i = 0; i < route.stops.length; i++) ...[
                              _RouteStopCard(
                                index: i,
                                stop: route.stops[i],
                                routeId: route.id,
                                isLast: i == route.stops.length - 1,
                                state: _stateFor(route),
                                onMoveUp: () => _moveUp(routeProvider, i),
                                onMoveDown: () => _moveDown(
                                    routeProvider, i, route.stops.length),
                                onRemove: () => _removeStop(routeProvider, i),
                                onRefresh: () => _refreshStop(
                                    routeProvider, venueProvider, i, route),
                              ),
                            ],
                            if (_stateFor(route) == RouteScreenState.edit) ...[
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => _onRegenerate(
                                    routeProvider, venueProvider, route),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Regenerate',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.refresh,
                                      color:
                                          AppColors.primary.withValues(alpha: 0.7),
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Bottom action button
              if (route != null)
                Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: _stateFor(route) == RouteScreenState.edit
                      ? _GoodToGoButton(
                          onTap: () => _onGoodToGo(routeProvider),
                          isReady: route.stops.isNotEmpty,
                        )
                      : _stateFor(route) == RouteScreenState.active
                          ? _StopHereButton(onTap: () => _onStopHere(routeProvider))
                          : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Route stop card ─────────────────────────────────────────────────────────
class _RouteStopCard extends StatefulWidget {
  final int index;
  final RouteStop stop;
  final String routeId;
  final bool isLast;
  final RouteScreenState state;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;
  final VoidCallback onRefresh;

  const _RouteStopCard({
    required this.index,
    required this.stop,
    required this.routeId,
    required this.isLast,
    required this.state,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.onRefresh,
  });

  @override
  State<_RouteStopCard> createState() => _RouteStopCardState();
}

class _RouteStopCardState extends State<_RouteStopCard> {
  bool _codeVisible = false;

  /// Client-side display code — a real check-in code system is a separate
  /// backlog item; this keeps the UI functional in the meantime.
  String get _uniqueCode {
    final prefix = widget.routeId.length >= 4
        ? widget.routeId.substring(0, 4).toUpperCase()
        : widget.routeId.toUpperCase().padRight(4, 'X');
    return '$prefix${100 + widget.index}';
  }

  @override
  Widget build(BuildContext context) {
    final stop = widget.stop;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        SizedBox(
          width: 50,
          child: Column(
            children: [
              // Number circle
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Dotted line
              if (!widget.isLast)
                CustomPaint(
                  size: const Size(2, 100),
                  painter: _DottedLinePainter(),
                ),
            ],
          ),
        ),

        // Card content
        Expanded(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          // Reorder arrows (edit) or nothing (active)
                          if (widget.state == RouteScreenState.edit)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: widget.onMoveUp,
                                  child: const Icon(Icons.arrow_drop_up, size: 28),
                                ),
                                GestureDetector(
                                  onTap: widget.onMoveDown,
                                  child: const Icon(Icons.arrow_drop_down, size: 28),
                                ),
                              ],
                            ),

                          // Venue image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: stop.venueImage,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => Container(
                                width: 70,
                                height: 70,
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.image_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Venue info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.venueName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (stop.estimatedDuration > 0)
                                  Text(
                                    '${stop.estimatedDuration} min',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.statusBlue,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons based on state
                    if (widget.state == RouteScreenState.edit)
                      const SizedBox.shrink()
                    else
                      // Show unique code / Cancel buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _codeVisible = !_codeVisible);
                                },
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _codeVisible
                                        ? const Color(0xFFFFE0E0)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _codeVisible ? _uniqueCode : 'Show unique code',
                                    style: TextStyle(
                                      color: _codeVisible
                                          ? AppColors.primary
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: _codeVisible ? 2 : 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right action icons
        if (widget.state == RouteScreenState.edit)
          Column(
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: widget.onRefresh,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.my_location, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 4),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 20),
              ),
            ],
          ),
      ],
    );
  }
}

// ── Dotted line painter ─────────────────────────────────────────────────────
class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 6.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── "Good To Go" button ─────────────────────────────────────────────────────
class _GoodToGoButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isReady;
  const _GoodToGoButton({required this.onTap, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isReady ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Good To Go',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: isReady ? 1.0 : 0.8),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.location_pin,
              color: Colors.white.withValues(alpha: isReady ? 1.0 : 0.8),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ── "Stop Here" button ──────────────────────────────────────────────────────
class _StopHereButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StopHereButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Stop Here',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.stop_circle_outlined, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}

// ── Thank You dialog ────────────────────────────────────────────────────────
class _ThankYouDialog extends StatefulWidget {
  const _ThankYouDialog();

  @override
  State<_ThankYouDialog> createState() => _ThankYouDialogState();
}

class _ThankYouDialogState extends State<_ThankYouDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: AppColors.primary.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_pin, size: 100, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(height: 24),
            const Text(
              '"Thank You!\nfor choosing us."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
