import 'package:api_anime/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../blocs/anime/anime_bloc.dart';
import '../widgets/loading_widget.dart';
import '../../core/utils/app_prefs.dart';
import '../widgets/responsive_center_layout.dart';

class AnimeDetailPage extends StatefulWidget {
  // PERBAIKAN: Terima animeId dari constructor
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
  // HAPUS: _animeId tidak perlu lagi di sini

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Panggil event di initState
    // Kita bisa akses BLoC-nya sendiri dan 'widget.animeId'
    print('📄 DetailPage: Fetching details for anime ID: ${widget.animeId}');
    context.read<AnimeBloc>().add(GetAnimeDetailsEvent(widget.animeId));
  }

  // HAPUS: Seluruh fungsi didChangeDependencies()

  @override
  Widget build(BuildContext context) {
    // HAPUS: Cek _animeId == null

    // PERBAIKAN: Gunakan widget.animeId
    final isFavorite = _appPreferences.isFavorite(widget.animeId);

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
              setState(() {});
            },
          ),
        ],
      ),
      body: ResponsiveCenterLayout(
        child: BlocBuilder<AnimeBloc, AnimeState>(
          builder: (context, state) {
            // PERBAIKAN: state Awal adalah AnimeInitial
            if (state is AnimeLoading || state is AnimeInitial) {
              return const LoadingWidget();
            } else if (state is AnimeDetailsLoaded) {
              // PERBAIKAN: Hapus pengecekan state.anime.malId != _animeId
              // Pengecekan itu tidak perlu lagi karena BLoC ini hanya untuk halaman ini

              final anime = state.anime;
              print('📄 DetailPage: Displaying anime: ${anime.title}');
              return SingleChildScrollView(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          anime.imageUrl,
                          height: 40.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Error loading image: $error');
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
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                    ),
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
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Title
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

                    // Information (Chip)
                    Row(
                      children: [
                        if (anime.type != null) ...[
                          _buildInfoChip(anime.type!),
                          SizedBox(width: 2.w),
                        ],
                        if (anime.episodes != null) ...[
                          _buildInfoChip('${anime.episodes} eps'),
                          SizedBox(width: 2.w),
                        ],
                        if (anime.status != null) ...[
                          _buildInfoChip(anime.status!),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Score and Rank
                    Row(
                      children: [
                        if (anime.score != null) ...[
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
                        if (anime.rank != null) ...[
                          SizedBox(width: 3.w),
                          Icon(Icons.trending_up, color: Colors.green, size: 5.w),
                          SizedBox(width: 1.w),
                          Text(
                            '#${anime.rank}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ], // <-- PERBAIKAN DI SINI (sebelumnya '}')
                    ),
                    SizedBox(height: 2.h),

                    // Synopsis
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

                    // Additional Information
                    if (anime.year != null || anime.season != null) ...[
                      Text(
                        'Information',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      if (anime.year != null)
                        _buildInfoRow('Year', anime.year.toString()),
                      if (anime.season != null)
                        _buildInfoRow('Season', anime.season!),
                      if (anime.source != null)
                        _buildInfoRow('Source', anime.source!),
                      if (anime.aired != null)
                        _buildInfoRow('Aired', anime.aired!),
                      if (anime.duration != null)
                        _buildInfoRow('Duration', anime.duration!),
                      if (anime.rating != null)
                        _buildInfoRow('Rating', anime.rating!),
                      SizedBox(height: 2.h),
                    ],

                    // Genres
                    if (anime.genres != null && anime.genres!.isNotEmpty) ...[
                      Text(
                        'Genres',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 1.h,
                        children: anime.genres!.map((genre) {
                          return _buildInfoChip(genre.name);
                        }).toList(),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Producers
                    if (anime.producers != null && anime.producers!.isNotEmpty) ...[
                      Text(
                        'Producers',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 1.h,
                        children: anime.producers!.map((producer) {
                          return _buildInfoChip(producer.name);
                        }).toList(),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Studios
                    if (anime.studios != null && anime.studios!.isNotEmpty) ...[
                      Text(
                        'Studios',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 1.h,
                        children: anime.studios!.map((studio) {
                          return _buildInfoChip(studio.name);
                        }).toList(),
                      ),
                      SizedBox(height: 2.h),
                    ],
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
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () {
                        // PERBAIKAN: Gunakan widget.animeId
                        context.read<AnimeBloc>().add(GetAnimeDetailsEvent(widget.animeId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            // Fallback
            return const LoadingWidget();
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.blue[900],
        ),
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
            width: 20.w,
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