import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/models/venue.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/providers/route_provider.dart';
import 'package:gtg/providers/venue_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/gtg_small_logo.dart';
import 'package:gtg/widgets/mini_map_view.dart';

/// Venue Detail screen — image carousel, about, venue info grid, location
/// map, and an "Add to the route" CTA. Nested inside the bottom-nav shell
/// so the nav bar stays visible when pushed from Home/Search/Routes.
class VenueDetailScreen extends StatefulWidget {
  final String venueId;
  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VenueProvider>().selectVenue(widget.venueId);
    });
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _addToRoute(Venue venue) async {
    final userId = context.read<AuthProvider>().user?.uid;
    if (userId == null) return;
    await context.read<RouteProvider>().addVenueToRoute(userId, venue);
    if (mounted) context.push('/routes');
  }

  @override
  Widget build(BuildContext context) {
    final venueProvider = context.watch<VenueProvider>();
    final venue = venueProvider.selected;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: venue == null
              ? _LoadingOrError(provider: venueProvider)
              : Stack(
                  children: [
                    Column(
                      children: [
                        SafeArea(
                          bottom: false,
                          child: _VenueHeader(
                            onMenuTap: () => context.go('/settings'),
                            onNotificationTap: () =>
                                context.push('/notification-settings'),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 110),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ImageCarousel(
                                  venue: venue,
                                  controller: _imageController,
                                  currentIndex: _imageIndex,
                                  onIndexChanged: (i) =>
                                      setState(() => _imageIndex = i),
                                  onBack: () => context.canPop()
                                      ? context.pop()
                                      : context.go('/home'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 16, 20, 0),
                                  child: _VenueHeaderInfo(venue: venue),
                                ),
                                if ((venue.description ?? '').isNotEmpty)
                                  _Section(
                                    title: 'About',
                                    child: Text(
                                      venue.description!,
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                if (venue.amenities.isNotEmpty)
                                  _Section(
                                    title: 'Venue Info',
                                    child: _AmenitiesGrid(
                                        amenities: venue.amenities),
                                  ),
                                _Section(
                                  title: 'Location',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.card),
                                    child: SizedBox(
                                      height: 160,
                                      child: MiniMapView(
                                        latitude:
                                            venue.location?.latitude ?? 0,
                                        longitude:
                                            venue.location?.longitude ?? 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: _AddToRouteButton(
                        onTap: () => _addToRoute(venue),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LoadingOrError extends StatelessWidget {
  final VenueProvider provider;
  const _LoadingOrError({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          provider.error ?? 'Venue not found.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}

// ── Header: hamburger + bell + small GTG mark ───────────────────────────────
class _VenueHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  const _VenueHeader({required this.onMenuTap, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onMenuTap,
            child: const Icon(Icons.menu_rounded,
                size: 28, color: AppColors.textPrimary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNotificationTap,
            child: const Icon(Icons.notifications_outlined,
                size: 26, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          const GtgSmallLogo(size: 32),
        ],
      ),
    );
  }
}

// ── Image carousel with back button + rating badge ─────────────────────────
class _ImageCarousel extends StatelessWidget {
  final Venue venue;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onBack;

  const _ImageCarousel({
    required this.venue,
    required this.controller,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final images = venue.images.isNotEmpty ? venue.images : [venue.imageUrl];

    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: PageView.builder(
              controller: controller,
              itemCount: images.length,
              onPageChanged: onIndexChanged,
              itemBuilder: (context, i) => CachedNetworkImage(
                imageUrl: images[i],
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.image_outlined,
                      size: 48, color: AppColors.primary),
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left_rounded,
                    size: 28, color: AppColors.primary),
              ),
            ),
          ),

          // Left/right arrows
          if (images.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () {
                    if (currentIndex > 0) {
                      controller.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () {
                    if (currentIndex < images.length - 1) {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],

          // Dot indicator
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),

          // Rating badge
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2E9E5B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    venue.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CarouselArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Name / category / price header ──────────────────────────────────────────
class _VenueHeaderInfo extends StatelessWidget {
  final Venue venue;
  const _VenueHeaderInfo({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(venue.name, style: AppTextStyles.venueName.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              venue.category,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Avg. ₹${venue.avgPricePerPerson}/ Person',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Shared "About / Venue Info / Location" section wrapper ─────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.primary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ── Venue info amenities grid ───────────────────────────────────────────────
class _AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;
  const _AmenitiesGrid({required this.amenities});

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('air') || l.contains(' ac') || l.startsWith('ac')) {
      return Icons.ac_unit_rounded;
    }
    if (l.contains('seat')) return Icons.event_seat_rounded;
    if (l.contains('payment') || l.contains('booking')) {
      return Icons.payments_rounded;
    }
    if (l.contains('cancel')) return Icons.policy_rounded;
    if (l.contains('park')) return Icons.local_parking_rounded;
    if (l.contains('cuisine')) return Icons.restaurant_menu_rounded;
    if (l.contains('indoor')) return Icons.home_rounded;
    if (l.contains('room')) return Icons.meeting_room_rounded;
    if (l.contains('float') || l.contains('capacity')) {
      return Icons.groups_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: amenities.map((a) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(a), size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  a,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Bottom fixed "Add to the route" CTA ─────────────────────────────────────
class _AddToRouteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddToRouteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppRadius.cardLarge),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        child: const SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.alt_route_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'Add to the route',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
