class Anime {
  final int malId;
  final String title;
  final String imageUrl;
  final String? synopsis;
  final double? score;
  final int? rank;
  final int? popularity;
  final int? members;
  final int? episodes;
  final String? type;
  final String? status;
  final int? year;
  final String? rating;
  final String? duration;
  final List<String> studios;
  final List<String> genres;
  final String? trailerUrl;
  final String? url;

  Anime({
    required this.malId,
    required this.title,
    required this.imageUrl,
    this.synopsis,
    this.score,
    this.rank,
    this.popularity,
    this.members,
    this.episodes,
    this.type,
    this.status,
    this.year,
    this.rating,
    this.duration,
    this.studios = const [],
    this.genres = const [],
    this.trailerUrl,
    this.url,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images != null ? images['jpg'] as Map<String, dynamic>? : null;
    final trailer = json['trailer'] as Map<String, dynamic>?;
    List<String> readNames(List<dynamic>? arr) =>
        (arr ?? const []).map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '').where((s) => s.isNotEmpty).toList();

    return Anime(
      malId: json['mal_id'] as int,
      title: (json['title'] ?? json['title_english'] ?? json['title_japanese'] ?? '') as String,
      imageUrl: (jpg?['large_image_url'] ?? jpg?['image_url'] ?? '') as String,
      synopsis: json['synopsis'] as String?,
      score: (json['score'] is int) ? (json['score'] as int).toDouble() : (json['score'] as num?)?.toDouble(),
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
      members: json['members'] as int?,
      episodes: json['episodes'] as int?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      year: json['year'] as int?,
      rating: json['rating'] as String?,
      duration: json['duration'] as String?,
      studios: readNames(json['studios'] as List<dynamic>?),
      genres: readNames(json['genres'] as List<dynamic>?),
      trailerUrl: (trailer?['url'] ?? trailer?['embed_url']) as String?,
      url: json['url'] as String?,
    );
  }
}
