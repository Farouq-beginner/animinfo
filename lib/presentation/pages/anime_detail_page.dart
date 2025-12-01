import 'package:api_anime/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:auto_size_text/auto_size_text.dart'; // IMPORT BARU
// Import Cubit dan State
import '../blocs/anime/anime_cubit.dart';
import '../blocs/anime/anime_state.dart';
import '../widgets/loading_widget.dart';
import '../../core/utils/app_prefs.dart';
import '../widgets/responsive_center_layout.dart';

class AnimeDetailPage extends StatefulWidget {
  final int animeId;

  const AnimeDetailPage({
    super.key,
    required this.animeId,
  });

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final AppPreferences _appPreferences = sl<AppPreferences>();

  @override
  void initState() {
    super.initState();
    print('📄 DetailPage: Fetching details for anime ID: ${widget.animeId}');
    context.read<AnimeCubit>().getAnimeDetails(widget.animeId);
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = _appPreferences.isFavorite(widget.animeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Details'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.link),
            onPressed: () async {
              final path = '/search/detail/${widget.animeId}';
              await Clipboard.setData(ClipboardData(text: path));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Link copied: $path')),
              );
            },
          ),
          StatefulBuilder(
            builder: (context, setStateIcon) {
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  if (isFavorite) {
                    await _appPreferences.removeFavorite(widget.animeId);
                  } else {
                    await _appPreferences.saveFavorite(widget.animeId);
                  }
                  setStateIcon(() {
                    isFavorite = !isFavorite;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: ResponsiveCenterLayout(
        child: BlocBuilder<AnimeCubit, AnimeState>(
          builder: (context, state) {
            if (state is AnimeLoading || state is AnimeInitial) {
              return const LoadingWidget();
            } else if (state is AnimeDetailsLoaded) {
              final anime = state.anime;
              final genres = anime.genres ?? [];
              final studios = anime.studios ?? [];

              return SingleChildScrollView(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. COVER IMAGE ---
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          anime.imageUrl,
                          height: 40.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 40.h,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 10.w,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 40.h,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // --- 2. TITLE ---
                    Text(
                      anime.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (anime.titleEnglish != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        anime.titleEnglish!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (anime.titleJapanese != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        anime.titleJapanese!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    SizedBox(height: 2.h),

                    // --- 3. INFO ROW (Type, Eps, Status) ---
                    Wrap( // Gunakan Wrap agar aman jika layar sempit
                      spacing: 2.w,
                      runSpacing: 1.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (anime.type != null)
                          _buildInfoChip(anime.type!),
                        if (anime.episodes != null)
                          _buildInfoChip('${anime.episodes} eps'),
                        if (anime.status != null)
                          _buildInfoChip(anime.status!),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // --- 4. SCORE ---
                    if (anime.score != null)
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 5.w),
                          SizedBox(width: 1.w),
                          Text(
                            anime.score!.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 2.h),

                    // --- 5. SYNOPSIS ---
                    Text(
                      'Synopsis',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      anime.synopsis ?? 'No synopsis available',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 2.h),

                    // --- 6. GENRES ---
                    if (genres.isNotEmpty) ...[
                      Text(
                        'Genres',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w, // Spacing sedikit diperbesar
                        runSpacing: 1.h,
                        children: genres.map((genre) {
                          return _buildInfoChip(genre.name);
                        }).toList(),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // --- 7. STUDIOS ---
                    if (studios.isNotEmpty) ...[
                      Text(
                        'Studios',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: studios.map((studio) {
                          return _buildInfoChip(studio.name);
                        }).toList(),
                      ),
                      SizedBox(height: 2.h),
                    ],
                    SizedBox(height: 50),
                  ],
                ),
              );
            } else if (state is AnimeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AnimeCubit>().getAnimeDetails(widget.animeId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const LoadingWidget();
          },
        ),
      ),
    );
  }

  // --- PERBAIKAN UTAMA PADA FUNGSI INI ---
  Widget _buildInfoChip(String text) {
    return Container(
      // Padding diperbesar agar chip terlihat lebih lega
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: AutoSizeText( // Gunakan AutoSizeText agar aman di Web
        text,
        style: TextStyle(
          fontSize: 12.sp, // Ukuran font diperbesar
          fontWeight: FontWeight.w500, // Sedikit lebih tebal
          color: Colors.blue[900],
        ),
        maxLines: 1,
        minFontSize: 10,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}