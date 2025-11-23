import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/anime/anime_bloc.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_widget.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/anime.dart';
import '../blocs/authentication/authentication_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 HomePage: Initializing and fetching anime');
      _fetchAnime();
    });
  }

  void _fetchAnime() {
    print('🔄 HomePage: Fetching anime...');
    try {
      if (context.read<AnimeBloc>().state is! TopAnimeLoaded) {
        context.read<AnimeBloc>().add(GetTopAnimeEvent());
      }
    } catch (e) {
      print('❌ HomePage: Error fetching anime: $e');
      _showErrorSnackBar('Failed to fetch anime: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage: Building widget');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AnimeBloc>().add(GetTopAnimeEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<AnimeBloc, AnimeState>(
        listener: (context, state) {
          print('🏠 HomePage: State changed to ${state.runtimeType}');
          if (state is AnimeError) {
            print('❌ HomePage: Showing error snackbar: ${state.message}');
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          print('🏠 HomePage: Building content for state ${state.runtimeType}');
          return _buildScrollableBody(state);
        },
      ),
    );
  }

  Widget _buildScrollableBody(AnimeState state) {
    // Build a single scrollable that includes the welcome card so it scrolls away with content.
    if (state is AnimeLoading || state is AnimeInitial) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AnimeBloc>().add(GetTopAnimeEvent());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverToBoxAdapter(child: SizedBox(height: 1.h)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: const LoadingWidget(),
            ),
          ],
        ),
      );
    } else if (state is TopAnimeLoaded) {
      if (state.animeList.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AnimeBloc>().add(GetTopAnimeEvent());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildWelcomeCard()),
              SliverToBoxAdapter(child: SizedBox(height: 1.h)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState('No anime found'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AnimeBloc>().add(GetTopAnimeEvent());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverPadding(
              padding: EdgeInsets.all(2.w),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8, // will be scaled by padding above
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final anime = state.animeList[index];
                    print('🏠 HomePage: Building anime card for index $index');
                    return AnimeCard(
                      anime: anime,
                      onTap: () {
                        print('🏠 HomePage: Tapped anime with ID ${anime.malId}');
                        context.push('/detail', extra: anime.malId);
                      },
                    );
                  },
                  childCount: state.animeList.length,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state is AnimeError) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<AnimeBloc>().add(GetTopAnimeEvent());
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildWelcomeCard()),
            SliverToBoxAdapter(child: SizedBox(height: 1.h)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(state.message),
            ),
          ],
        ),
      );
    }
    // Fallback
    _fetchAnime();
    return const LoadingWidget();
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          String name = 'User';
          if (authState is AuthenticationAuthenticated) {
            name = authState.user.username;
          }
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.2.h),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 10.w,
                      color:Color(0xFF0D47A1)
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(AnimeState state) {
    if (state is AnimeLoading || state is AnimeInitial) {
      print('🏠 HomePage: Showing loading state');
      return const LoadingWidget();
    } else if (state is TopAnimeLoaded) {
      print('🏠 HomePage: Showing loaded state with ${state.animeList.length} anime');
      if (state.animeList.isEmpty) {
        return _buildEmptyState('No anime found');
      }
      return _buildAnimeGrid(state.animeList);
    } else if (state is AnimeError) {
      print('🏠 HomePage: Showing error state: ${state.message}');
      return _buildErrorState(state.message);
    }
    print('🏠 HomePage: State tidak relevan, fetch ulang...');
    _fetchAnime();
    return const LoadingWidget();
  }

  Widget _buildAnimeGrid(List<Anime> animeList) {
    print('🏠 HomePage: Building grid with ${animeList.length} items');
    return RefreshIndicator(
      onRefresh: () async {
        print('🏠 HomePage: Refresh triggered');
        context.read<AnimeBloc>().add(GetTopAnimeEvent());
      },
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.7,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
          ),
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            print('🏠 HomePage: Building anime card for index $index');
            return AnimeCard(
              anime: anime,
              onTap: () {
                print('🏠 HomePage: Tapped anime with ID ${anime.malId}');
                context.push('/detail', extra: anime.malId);
              },
            );
          },
        ),
      ),
    );
  }
  Widget _buildEmptyState(String message) {
    // ... (Fungsi ini biarkan sama) ...
    print('🏠 HomePage: Building empty state: $message');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tv_off,
            size: 20.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              context.read<AnimeBloc>().add(GetTopAnimeEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    // ... (Fungsi ini biarkan sama) ...
    print('🏠 HomePage: Building error state: $message');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 20.w,
            color: Colors.red[400],
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              'Error loading data',
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              context.read<AnimeBloc>().add(GetTopAnimeEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}