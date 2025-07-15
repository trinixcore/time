import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Core imports
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/services/supabase_service.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/logger.dart';
import 'shared/widgets/custom_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable browser console logging by default
  AppLogger.setBrowserConsoleEnabled(false);

  runApp(
    // Wrap app in ProviderScope for Riverpod state management
    ProviderScope(child: AppInitializer()),
  );
}

class AppInitializer extends StatefulWidget {
  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String _initializationMessage = 'Initializing TRINIX...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initializationMessage = 'Connecting to Firebase...';
      });

      // Initialize Firebase for web
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      setState(() {
        _initializationMessage = 'Loading configuration...';
      });

      // Initialize Supabase with dynamic configuration
      await SupabaseService.initializeWithDynamicConfig();

      setState(() {
        _initializationMessage = 'Setting up authentication...';
      });

      // Add a small delay to show the loader
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _initializationMessage = 'Loading application...';
      });

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initializationMessage = 'Failed to initialize: ${e.toString()}';
      });
      // Still show the app even if there's an error
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
        ),
        home: Scaffold(
          backgroundColor: Colors.grey[50],
          body: CustomLoader(message: _initializationMessage, size: 120),
        ),
      );
    }

    return TimeManagementApp();
  }
}

class TimeManagementApp extends ConsumerWidget {
  const TimeManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Brand Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3), // Professional blue
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),

      // Dark Theme Configuration
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
        ),
      ),

      // System theme mode
      themeMode: ThemeMode.system,

      // Bootstrap AppRouter
      routerConfig: router,
    );
  }
}
