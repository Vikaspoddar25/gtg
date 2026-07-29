import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Settings;
import 'package:provider/provider.dart';
import 'package:gtg/firebase_options.dart';
import 'package:gtg/providers/auth_provider.dart';
import 'package:gtg/providers/chat_provider.dart';
import 'package:gtg/providers/gtg_flow_provider.dart';
import 'package:gtg/providers/notification_provider.dart';
import 'package:gtg/providers/route_provider.dart';
import 'package:gtg/providers/user_provider.dart';
import 'package:gtg/providers/venue_provider.dart';
import 'package:gtg/services/database_service.dart';
import 'package:gtg/theme/theme.dart';
import 'package:gtg/utils/router.dart';

/// Public Mapbox access token, supplied at build/run time via:
///   flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx
/// Falls back to `/config/app.mapboxPublicToken` in Firestore if unset,
/// so the token can be rotated without a client release.
const String _mapboxDartDefineToken =
    String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore settings
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 50 * 1024 * 1024, // 50 MB
  );

  await _configureMapbox(firestore);

  runApp(const GtgApp());
}

/// Resolves the Mapbox public access token (dart-define first, else the
/// remote app config) and applies it before any [MapWidget] is built.
/// Safe to call even if Mapbox isn't configured yet — maps simply won't
/// render on Android/iOS until a token is supplied; web always shows the
/// static map placeholder regardless (see `MiniMapView`), since the stable
/// Mapbox Flutter SDK has no web renderer yet.
Future<void> _configureMapbox(FirebaseFirestore firestore) async {
  if (kIsWeb) return;
  var token = _mapboxDartDefineToken;
  if (token.isEmpty) {
    try {
      final doc = await firestore.collection('config').doc('app').get();
      token = doc.data()?['mapboxPublicToken'] as String? ?? '';
    } catch (_) {
      // Config doc may not exist yet — non-fatal, maps stay disabled.
    }
  }
  if (token.isNotEmpty) {
    MapboxOptions.setAccessToken(token);
  }
}

class GtgApp extends StatelessWidget {
  const GtgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider(create: (_) => DatabaseService()),

        // Auth (must come before feature providers that depend on user ID)
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),

        // Feature providers wired to DatabaseService
        ChangeNotifierProxyProvider<DatabaseService, VenueProvider>(
          create: (ctx) => VenueProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? VenueProvider(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, RouteProvider>(
          create: (ctx) => RouteProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? RouteProvider(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
          create: (ctx) => UserProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? UserProvider(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, NotificationProvider>(
          create: (ctx) => NotificationProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? NotificationProvider(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, ChatProvider>(
          create: (ctx) => ChatProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? ChatProvider(db),
        ),

        // UI-only providers
        ChangeNotifierProvider(create: (_) => GtgFlowProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = buildRouter(auth);
          return MaterialApp.router(
            title: 'GTG',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}

