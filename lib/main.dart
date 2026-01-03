import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: BeloteRoyaleApp(),
    ),
  );
}

class BeloteRoyaleApp extends StatefulWidget {
  const BeloteRoyaleApp({super.key});

  @override
  State<BeloteRoyaleApp> createState() => _BeloteRoyaleAppState();
}

class _BeloteRoyaleAppState extends State<BeloteRoyaleApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate initialization time (loading assets, checking auth, etc.)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'MR BELOTE',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'MR BELOTE',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
