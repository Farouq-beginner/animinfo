import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/anime_api_service.dart';
import '../models/anime.dart';

class AnimeDetailPage extends StatefulWidget {
  final int malId;
  const AnimeDetailPage({super.key, required this.malId});

  @override
  _AnimeDetailPageState createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final AnimeApiService apiService = AnimeApiService();
  late Future<Anime> _futureAnime;

  @override
  void initState() {
    super.initState();
    _futureAnime = apiService.fetchAnimeDetail(widget.malId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Anime Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Copy link',
            onPressed: () {
              final link = '${Uri.base.origin}/home/anime/${widget.malId}';
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied link: $link')),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<Anime>(
        future: _futureAnime,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final anime = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    anime.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  anime.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (anime.type != null) _chip('Type', anime.type!),
                    if (anime.status != null) _chip('Status', anime.status!),
                    if (anime.episodes != null) _chip('Episodes', '${anime.episodes}'),
                    if (anime.score != null) _chip('Score', anime.score!.toString()),
                    if (anime.rank != null) _chip('Rank', '#${anime.rank}'),
                    if (anime.popularity != null) _chip('Popularity', '${anime.popularity}'),
                    if (anime.year != null) _chip('Year', '${anime.year}'),
                    if (anime.rating != null) _chip('Rating', anime.rating!),
                    if (anime.duration != null) _chip('Duration', anime.duration!),
                  ],
                ),
                const SizedBox(height: 12),
                if (anime.genres.isNotEmpty) ...[
                  const Text('Genres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: anime.genres.map((g) => Chip(label: Text(g))).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (anime.studios.isNotEmpty) ...[
                  const Text('Studios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: anime.studios.map((s) => Chip(label: Text(s))).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                const Text('Synopsis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(anime.synopsis ?? '-'),
                const SizedBox(height: 12),
                if (anime.trailerUrl != null)
                  Row(
                    children: [
                      const Icon(Icons.ondemand_video),
                      const SizedBox(width: 8),
                      Flexible(child: Text(anime.trailerUrl!, style: const TextStyle(color: Colors.blue))),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _chip(String label, String value) {
  return Chip(
    label: Text('$label: $value'),
    visualDensity: VisualDensity.compact,
  );
}
