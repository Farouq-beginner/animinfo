import 'package:api_anime/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
// UBAH: Import Cubit dan State terpisah
import '../blocs/splash/splash_cubit.dart';
import '../blocs/splash/splash_state.dart';
import '../../core/constants/app_constants.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // UBAH: Panggil function checkLoginStatus(), bukan add(Event)
      create: (context) => sl<SplashCubit>()..checkLoginStatus(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashAuthenticated) {
          context.go('/home');
        } else if (state is SplashUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blue[900],
        body: Stack(
          children: [
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final media = MediaQuery.of(context);
                  final shortest = media.size.shortestSide;
                  // Make size flexible based on available space
                  final baseSize = shortest * 0.45; // 45% of shortest side
                  // Clamp size to avoid extreme values on very small/large screens
                  final size = baseSize.clamp(120.0, 360.0);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(size * 0.27),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: EdgeInsets.all(size * 0.06),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Image.asset('assets/images/logo.png'),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        AppConstants.appName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      BlocBuilder<SplashCubit, SplashState>(
                        builder: (context, state) {
                          if (state is SplashLoading) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: 40.w,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.blue[700],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 2.h,
              child: Text(
                'BY KELOMPOK 5',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}