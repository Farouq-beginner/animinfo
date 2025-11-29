import 'package:api_anime/main.dart';
import 'package:api_anime/presentation/pages/about_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/anime_detail_page.dart';
import 'presentation/blocs/anime/anime_cubit.dart';
import 'core/constants/route_constants.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterPage(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) {
        final animeId = state.extra as int;

        return BlocProvider(
          create: (context) => sl<AnimeCubit>(),
          child: AnimeDetailPage(animeId: animeId),
        );
      },
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
);