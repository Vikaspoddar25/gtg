import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore settings
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 50 * 1024 * 1024, // 50 MB
  );

  runApp(const GtgApp());
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

