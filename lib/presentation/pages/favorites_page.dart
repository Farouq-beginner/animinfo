import 'dart:async';
import 'package:api_anime/domain/entities/anime.dart';
import 'package:api_anime/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_widget.dart';
import '../../core/utils/app_prefs.dart';
import '../../domain/usecases/get_anime_details.dart';
import 'package:dartz/dartz.dart' hide State;
import '../../core/errors/failures.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

// Sekarang 'State' di sini pasti merujuk ke State milik Flutter
class _FavoritesPageState extends State<FavoritesPage> {
  final AppPreferences _appPreferences = sl<AppPreferences>();
  final GetAnimeDetails _getAnimeDetails = sl<GetAnimeDetails>();

  List<int> _favoriteIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState(); // Error 'initState' akan hilang
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() { // Error 'setState' akan hilang
      _isLoading = true;
    });

    final favorites = _appPreferences.getFavorites();
    setState(() { // Error 'setState' akan hilang
      _favoriteIds = favorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _favoriteIds.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadFavorites,
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.7,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 2.w,
            ),
            itemCount: _favoriteIds.length,
            itemBuilder: (context, index) {
              final animeId = _favoriteIds[index];

              return FutureBuilder<Either<Failure, Anime>>(
                future: _getAnimeDetails(animeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildLoadingCard();
                  } else if (snapshot.hasError) {
                    return _buildErrorCard('Error');
                  } else if (snapshot.hasData) {
                    // 'Either' dari dartz masih berfungsi
                    return snapshot.data!.fold(
                          (failure) => _buildErrorCard(failure.message),
                          (anime) => AnimeCard(
                        anime: anime,
                        onTap: () {
                          context.goNamed(
                            'favorites-detail',
                            pathParameters: {'id': anime.malId.toString()},
                          );
                        },
                      ),
                    );
                  }
                  return _buildErrorCard('Unknown Error');
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 20.w, color: Colors.grey[400]),
          SizedBox(height: 2.h),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: LoadingWidget(),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red),
              SizedBox(height: 1.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.sp, color: Colors.red[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}