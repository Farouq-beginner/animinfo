import 'media_item.dart';
class Anime extends MediaItem {
  final int? _episodes; // anime-specific field

  Anime({
    required int malId,
    required String title,
    required String imageUrl,
    String? synopsis,
    double? score,
    int? rank,
    int? popularity,
    int? members,
    int? episodes,
    String? type,
    String? status,
    int? year,
    String? rating,
    String? duration,
    List<String> studios = const [],
    List<String> genres = const [],
    String? trailerUrl,
    String? url,
  })  : _episodes = episodes,
        super(
          malId: malId,
          title: title,
          imageUrl: imageUrl,
          synopsis: synopsis,
          score: score,
          rank: rank,
          popularity: popularity,
          members: members,
          type: type,
          status: status,
          year: year,
          rating: rating,
          duration: duration,
          studios: studios,
          genres: genres,
          trailerUrl: trailerUrl,
          url: url,
        );

  int? get episodes => _episodes; // encapsulated getter

  @override
  String get mediaKind => 'anime';

  @override
  double engagementScore() {
    // Boost engagement slightly if long-running (episodes > 50).
    final base = super.engagementScore();
    if ((_episodes ?? 0) > 50) return base * 1.05;
    return base;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['episodes'] = _episodes;
    return json;
  }

  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images != null ? images['jpg'] as Map<String, dynamic>? : null;
    final trailer = json['trailer'] as Map<String, dynamic>?;
    List<String> readNames(List<dynamic>? arr) => (arr ?? const [])
        .map((e) => (e as Map<String, dynamic>)['name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return Anime(
      malId: json['mal_id'] as int,
      title: (json['title'] ?? json['title_english'] ?? json['title_japanese'] ?? '') as String,
      imageUrl: (jpg?['large_image_url'] ?? jpg?['image_url'] ?? '') as String,
      synopsis: json['synopsis'] as String?,
      score: (json['score'] is int) ? (json['score'] as int).toDouble() : (json['score'] as num?)?.toDouble(),
      rank: json['rank'] as int?,
      popularity: json['popularity'] is int ? json['popularity'] as int : null,
      members: json['members'] is int ? json['members'] as int : null,
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
