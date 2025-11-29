import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/anime/anime_cubit.dart';
import '../blocs/anime/anime_state.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_widget.dart';
import '../../domain/entities/anime.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAnime(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isSearched = true;
      });
      context.read<AnimeCubit>().searchAnime(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Anime'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          children: [
            // Search Field (Sekarang Full Width)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for anime...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearched = false;
                    });
                    // Reset search result
                    context.read<AnimeCubit>().searchAnime('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: _searchAnime,
            ),
            SizedBox(height: 2.h),

            // Search Results
            Expanded(
              child: BlocConsumer<AnimeCubit, AnimeState>(
                listener: (context, state) {
                  if (state is AnimeError && _isSearched) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildContent(state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AnimeState state) {
    if (!_isSearched) {
      return Center(
        child: Text(
          'Search for your favorite anime',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    if (state is AnimeLoading) {
      return const LoadingWidget();
    } else if (state is SearchAnimeLoaded) {
      // Langsung tampilkan hasil tanpa filter lokal
      if (state.animeList.isEmpty) {
        return _buildEmptyState('No results found');
      }
      return _buildAnimeGrid(state.animeList);
    } else if (state is AnimeError) {
      return _buildErrorState();
    }

    // Jika state masih TopAnimeLoaded (misal baru pindah dari home), tampilkan initial message
    if (state is TopAnimeLoaded) {
      return Center(
        child: Text(
          'Search for your favorite anime',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return _buildEmptyState('No search results');
  }

  Widget _buildAnimeGrid(List<Anime> animeList) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];
        return AnimeCard(
          anime: anime,
          onTap: () {
            context.push('/detail', extra: anime.malId);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
          Text(
            'Error searching anime',
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchAnime(_searchController.text);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}