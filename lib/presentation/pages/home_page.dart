import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/anime/anime_bloc.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_widget.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/anime.dart';

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
          return _buildContent(state);
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