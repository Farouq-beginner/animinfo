import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'pages/anime_list_page.dart';
import 'pages/anime_detail_page.dart';
import 'splashscreen/splash_screen.dart';
import 'router/splash_state.dart';

void main() {
  // Remove '#' from Flutter web URLs by using path URL strategy.
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      // Start at root; we'll show splash first on a fresh load/refresh.
      initialLocation: '/',
      redirect: (context, state) {
        // Show splash only when landing at home on a fresh load.
        // Deep links like /home/anime/:id should NOT be redirected to splash.
        if (!SplashState.shown) {
          final path = state.uri.path;
          if (path == '/' || path == '/home') {
            // If user requested /home explicitly on first load, show splash then go to /home.
            SplashState.pendingPath = '/home';
            return '/';
          }
          // Otherwise, allow deep link to proceed without splash.
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const AnimeListPage(),
        ),
        GoRoute(
          path: '/home/anime/:id',
          builder: (context, state) {
            final idStr = state.pathParameters['id'];
            final malId = int.tryParse(idStr ?? '');
            if (malId == null) {
              // Fallback to home if id invalid
              return const AnimeListPage();
            }
            return AnimeDetailPage(malId: malId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}