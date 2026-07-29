import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gtg/providers/venue_provider.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';
import 'package:gtg/widgets/mini_map_view.dart';
import 'package:gtg/widgets/venue_card.dart';

// Default map center — Kalkaji, New Delhi (used until live user location
// wiring lands; see todo.md Phase D).
const double _kDefaultLat = 28.5480;
const double _kDefaultLng = 77.2588;
const String _kDefaultCity = 'New Delhi';

// ── Figma asset URLs (frame 117:105) ──────────────────────────────────────
const _kGtgLogo =
    'https://www.figma.com/api/mcp/asset/437725d6-17ed-4e89-ae0c-9c9d40359b10';
const _kFriends =
    'https://www.figma.com/api/mcp/asset/982bded8-f2eb-4b28-b7a4-dd8cd716353d';


// Mode icon URLs
const _kPizzaIcon =
    'https://www.figma.com/api/mcp/asset/5d1d7d05-f05b-426c-ae99-f5a03a78114c';
const _kAdventureIcon =
    'https://www.figma.com/api/mcp/asset/7e90d8fe-0302-4c0f-9dfd-4e95b620a105';
const _kSlideIcon =
    'https://www.figma.com/api/mcp/asset/34ea289e-ceb6-4944-b109-ef3f332b5ce7';
const _kWineIcon =
    'https://www.figma.com/api/mcp/asset/cbe6c89e-ed5f-43b6-818c-46dbf7cf5442';
const _kBillboardIcon =
    'https://www.figma.com/api/mcp/asset/37e1613a-f78c-4cd1-8614-6e98b58448e8';

/// Home / discovery screen.
/// Figma reference: frame 117:105 (iPhone 14 & 15 Pro Max - 11)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGroupMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VenueProvider>().loadVenues(city: _kDefaultCity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Stack(
            children: [
              // ── Map background (opacity 40%, 277px from top of screen) ──
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.4,
                  child: SizedBox(
                    height: 277,
                    width: double.infinity,
                    child: MiniMapView(
                      latitude: _kDefaultLat,
                      longitude: _kDefaultLng,
                      zoom: 13,
                      showMarker: false,
                      interactive: false,
                    ),
                  ),
                ),
              ),

              // ── Scrollable content ───────────────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.only(top: 90, bottom: 101),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero: GTG logo + friends (169px = 259-90) ──────────
                    _HeroSection(isGroupMode: _isGroupMode),

                    // ── Pink / red gradient content container ─────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppGradients.homeSurface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                        border: Border.all(
                          color: AppColors.primaryBorder,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 26),

                          // "Let's Good To Go!" card
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: const _LetsGoCard(),
                          ),

                          const SizedBox(height: 24),

                          // Suggestion chip — copy varies with Group/Person mode
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: _WhatNearMeChip(
                              label: _isGroupMode
                                  ? "What's near me"
                                  : 'Want to spend quality time',
                              onTap: () => context.go('/search'),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Venue list — live from Firestore via VenueProvider
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Consumer<VenueProvider>(
                              builder: (context, venueProvider, _) {
                                if (venueProvider.isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                }
                                if (venueProvider.venues.isEmpty) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 24),
                                    child: Center(
                                      child: Text(
                                        venueProvider.hasError
                                            ? "Couldn't load venues. Pull to refresh."
                                            : 'No venues nearby yet.',
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: venueProvider.venues
                                      .map((v) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12),
                                            child: VenueCard(
                                              venue: v,
                                              onTap: () =>
                                                  context.push('/venue/${v.id}'),
                                            ),
                                          ))
                                      .toList(),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          // "Search by modes" section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child:
                                const _SearchByModesSection(),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Fixed header ──────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _TopHeader(
                  isGroupMode: _isGroupMode,
                  onToggle: () => setState(() => _isGroupMode = !_isGroupMode),
                  onMenuTap: () => context.go('/settings'),
                  onNotificationTap: () => context.go('/notification-settings'),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}

// ── Top header (gradient, hamburger, bell, toggle pill) ───────────────────
class _TopHeader extends StatelessWidget {
  final bool isGroupMode;
  final VoidCallback onToggle;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

  const _TopHeader({
    required this.isGroupMode,
    required this.onToggle,
    required this.onMenuTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        gradient: AppGradients.topHeader,
      ),
      padding: const EdgeInsets.only(
          left: 20, right: 20, bottom: 12, top: 0),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hamburger
            GestureDetector(
              onTap: onMenuTap,
              child: const Icon(Icons.menu_rounded,
                  size: 28, color: AppColors.textPrimary),
            ),
            const Spacer(),
            // Bell
            GestureDetector(
              onTap: onNotificationTap,
              child: const Icon(Icons.notifications_outlined,
                  size: 26, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 10),
            // Toggle pill (red circle + yellow pill)
            _TogglePill(isGroupMode: isGroupMode, onToggle: onToggle),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final bool isGroupMode;
  final VoidCallback onToggle;

  const _TogglePill({required this.isGroupMode, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 77,
        height: 34,
        decoration: BoxDecoration(
          color: isGroupMode ? AppColors.primary : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(AppRadius.input),
          boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(-1, 4), blurRadius: 3)],
        ),
        child: Stack(
          children: [
            // Label
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isGroupMode ? Icons.people_rounded : Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
            // Sliding dot
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: isGroupMode ? 49 : 6,
              top: 5,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isGroupMode ? const Color(0xFFFFD700) : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero: GTG logo + friends/couple illustration (mode-dependent) ─────────
class _HeroSection extends StatelessWidget {
  final bool isGroupMode;
  const _HeroSection({required this.isGroupMode});

  @override
  Widget build(BuildContext context) {
    // Figma absolute positions (relative to scroll content start at screen y=90):
    //   GTG logo:  top:80  → scroll offset = 80-90 = -10 → appears at top:0
    //   Friends:   top:147 → scroll offset = 147-90 = 57
    //   Container: top:259 → scroll offset = 259-90 = 169  (= hero height)
    return SizedBox(
      height: 169,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // GTG pin logo — centered, at very top of hero
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.network(
                _kGtgLogo,
                width: 112,
                height: 79,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.location_pin,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // Group/Couple illustration — overlaps bottom of logo.
          // Couple mode uses an icon placeholder until a final Figma asset
          // is available (see plan-master-development.md).
          Positioned(
            top: 57,
            left: 0,
            right: 0,
            child: Center(
              child: isGroupMode
                  ? Image.network(
                      _kFriends,
                      width: 216,
                      height: 112,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.people_alt_rounded,
                        size: 90,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.favorite_rounded,
                      size: 90,
                      color: AppColors.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── "Let's Good To Go!" card ───────────────────────────────────────────────
class _LetsGoCard extends StatelessWidget {
  const _LetsGoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("Let's Good To Go!",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      )),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kalkaji, New Delhi ; ${TimeOfDay.now().format(context)} UTC',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.primary, size: 22),
                  ],
                ),
              ],
            ),
          ),
          // Start button (bottom section of card)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.cardLarge),
              bottomRight: Radius.circular(AppRadius.cardLarge),
            ),
            child: Material(
              color: AppColors.primary,
              child: InkWell(
                onTap: () => context.go('/gtg-flow'),
                child: SizedBox(
                  height: 79,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Start',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion chip (copy varies with Group/Person mode) ──────────────────
class _WhatNearMeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WhatNearMeChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        constraints: const BoxConstraints(minWidth: 165),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: const [AppShadows.card],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── "Search by modes" section ─────────────────────────────────────────────
class _SearchByModesSection extends StatelessWidget {
  const _SearchByModesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 179,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            boxShadow: const [AppShadows.card],
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'Search by modes',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.panel),
            boxShadow: const [AppShadows.card],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              // Top row of modes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _ModeItem(imgUrl: _kPizzaIcon, label: 'Foodie', size: 80),
                  _ModeItem(
                      imgUrl: _kAdventureIcon, label: 'Explorer', size: 80),
                  _ModeItem(
                      imgUrl: _kSlideIcon, label: 'Adventurous', size: 60),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 8),
              // Bottom row of modes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _ModeItem(imgUrl: _kWineIcon, label: 'Chillaxed', size: 60),
                  _ModeItem(
                      imgUrl: _kBillboardIcon,
                      label: 'Unseen Events',
                      size: 60),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeItem extends StatelessWidget {
  final String imgUrl;
  final String label;
  final double size;
  const _ModeItem(
      {required this.imgUrl, required this.label, required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/search'),
      child: Column(
        children: [
          Image.network(
            imgUrl,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                Icon(Icons.category_rounded, size: size * 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

