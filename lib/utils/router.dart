import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/screens/edit_profile_screen.dart';
import 'package:gtg/screens/good_to_go_screen.dart';
import 'package:gtg/screens/home_screen.dart';
import 'package:gtg/screens/location_permission_screen.dart';
import 'package:gtg/screens/news_screen.dart';
import 'package:gtg/screens/no_internet_screen.dart';
import 'package:gtg/screens/notification_settings_screen.dart';
import 'package:gtg/screens/otp_screen.dart';
import 'package:gtg/screens/phone_input_screen.dart';
import 'package:gtg/screens/gtg_flow_screen.dart';
import 'package:gtg/screens/generating_route_screen.dart';
import 'package:gtg/screens/refer_earn_screen.dart';
import 'package:gtg/screens/routes_screen.dart';
import 'package:gtg/screens/search_screen.dart';
import 'package:gtg/screens/settings_screen.dart';
import 'package:gtg/screens/sign_in_screen.dart';
import 'package:gtg/screens/sign_up_screen.dart';
import 'package:gtg/screens/splash_screen.dart';
import 'package:gtg/screens/venue_detail_screen.dart';
import 'package:gtg/screens/verified_screen.dart';
import 'package:gtg/widgets/gtg_bottom_nav.dart';

/// Routes that don't require authentication.
const _publicPaths = {
  '/signin',
  '/signup',
  '/phone-input',
  '/otp',
  '/verified',
  '/good-to-go',
  '/welcome-back',
  '/no-internet',
};

/// Key for the shell navigator (bottom-nav screens).
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Central router with ShellRoute for persistent bottom nav + auth guards.
GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/signin',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthed = authProvider.isAuthenticated;
      final path = state.uri.path;
      final isPublic = _publicPaths.contains(path);

      // If not authenticated and trying to access protected route → sign in
      if (!isAuthed && !isPublic) return '/signin';

      // If authenticated and on sign-in/sign-up → go home
      if (isAuthed && (path == '/signin' || path == '/signup')) return '/home';

      return null; // No redirect
    },
    routes: [
      // ── Public / Auth routes (no bottom nav) ────────────────────────────
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/phone-input',
        name: 'phoneInput',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/verified',
        name: 'verified',
        builder: (context, state) => const VerifiedScreen(),
      ),
      GoRoute(
        path: '/good-to-go',
        name: 'goodToGo',
        builder: (context, state) => const GoodToGoScreen(),
      ),
      GoRoute(
        path: '/welcome-back',
        name: 'welcomeBack',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/no-internet',
        name: 'noInternet',
        builder: (context, state) => NoInternetScreen(
          onRetry: () => state.uri.toString(),
        ),
      ),
      GoRoute(
        path: '/location-permission',
        name: 'locationPermission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),

      // ── Shell route with persistent bottom nav ─────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ShellScaffold(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/gtg-flow',
            name: 'gtgFlow',
            builder: (context, state) => const GtgFlowScreen(),
          ),
          GoRoute(
            path: '/generating-route',
            name: 'generatingRoute',
            builder: (context, state) => const GeneratingRouteScreen(),
          ),
          GoRoute(
            path: '/routes',
            name: 'routes',
            builder: (context, state) => const RoutesScreen(),
          ),
          GoRoute(
            path: '/news',
            name: 'news',
            builder: (context, state) => const NewsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/notification-settings',
            name: 'notificationSettings',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: '/venue/:venueId',
            name: 'venueDetail',
            builder: (context, state) => VenueDetailScreen(
              venueId: state.pathParameters['venueId']!,
            ),
          ),
          GoRoute(
            path: '/refer-earn',
            name: 'referEarn',
            builder: (context, state) => const ReferEarnScreen(),
          ),
          GoRoute(
            path: '/edit-profile',
            name: 'editProfile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Shell scaffold that wraps bottom-nav screens with the persistent nav bar.
class _ShellScaffold extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const _ShellScaffold({required this.state, required this.child});

  /// Groups of paths that share a bottom-nav tab index. `/gtg-flow` and
  /// `/routes` are the same "Route" tab — the wizard feeds into the
  /// generated route, so the tab stays highlighted across both.
  static const _tabGroups = [
    ['/home'],
    ['/search'],
    ['/gtg-flow', '/generating-route', '/routes'],
    ['/news'],
    ['/settings'],
  ];

  @override
  Widget build(BuildContext context) {
    final path = state.uri.path;
    final currentIndex = _tabGroups
        .indexWhere((group) => group.contains(path))
        .clamp(0, _tabGroups.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: GtgBottomNav(currentIndex: currentIndex),
    );
  }
}
