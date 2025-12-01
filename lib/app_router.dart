import 'package:api_anime/main.dart';
import 'package:api_anime/presentation/pages/about_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/anime_detail_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/favorites_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/blocs/anime/anime_cubit.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      name: 'splash',
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    // Shell with bottom navigation; URL reflects selected tab
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          name: 'home',
          path: '/home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              name: 'home-detail',
              path: 'detail/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final animeId = int.tryParse(idStr ?? '');
                return BlocProvider(
                  create: (context) => sl<AnimeCubit>(),
                  child: AnimeDetailPage(animeId: animeId ?? 0),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: 'search',
          path: '/search',
          builder: (context, state) => const SearchPage(),
          routes: [
            GoRoute(
              name: 'search-detail',
              path: 'detail/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final animeId = int.tryParse(idStr ?? '');
                return BlocProvider(
                  create: (context) => sl<AnimeCubit>(),
                  child: AnimeDetailPage(animeId: animeId ?? 0),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: 'favorites',
          path: '/favorites',
          builder: (context, state) => const FavoritesPage(),
          routes: [
            GoRoute(
              name: 'favorites-detail',
              path: 'detail/:id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final animeId = int.tryParse(idStr ?? '');
                return BlocProvider(
                  create: (context) => sl<AnimeCubit>(),
                  child: AnimeDetailPage(animeId: animeId ?? 0),
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      name: 'detail',
      parentNavigatorKey: _rootNavigatorKey,
      path: '/detail/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final animeId = int.tryParse(idStr ?? '');
        return BlocProvider(
          create: (context) => sl<AnimeCubit>(),
          child: AnimeDetailPage(animeId: animeId ?? 0),
        );
      },
    ),
    GoRoute(
      name: 'about',
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithNavBar({required this.child});

  static final _tabs = <String>[
    '/home',
    '/search',
    '/favorites',
    '/profile',
  ];

  int _locationToTabIndex(BuildContext context) {
    final String loc = GoRouterState.of(context).uri.toString();
    final idx = _tabs.indexWhere((p) => loc.startsWith(p));
    return idx >= 0 ? idx : 0;
  }

  void _onTap(BuildContext context, int index) {
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _locationToTabIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}