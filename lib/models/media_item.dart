abstract class MediaItem {
  // Encapsulated private fields
  final int _malId;
  final String _title;
  final String _imageUrl;
  final String? _synopsis;
  final double? _score;
  final int? _rank;
  final int? _popularity;
  final int? _members;
  final String? _type;
  final String? _status;
  final int? _year;
  final String? _rating;
  final String? _duration;
  final List<String> _studios;
  final List<String> _genres;
  final String? _trailerUrl;
  final String? _url;

  MediaItem({
    required int malId,
    required String title,
    required String imageUrl,
    String? synopsis,
    double? score,
    int? rank,
    int? popularity,
    int? members,
    String? type,
    String? status,
    int? year,
    String? rating,
    String? duration,
    List<String> studios = const [],
    List<String> genres = const [],
    String? trailerUrl,
    String? url,
  })  : _malId = malId,
        _title = title,
        _imageUrl = imageUrl,
        _synopsis = synopsis,
        _score = score,
        _rank = rank,
        _popularity = popularity,
        _members = members,
        _type = type,
        _status = status,
        _year = year,
        _rating = rating,
        _duration = duration,
        _studios = studios,
        _genres = genres,
        _trailerUrl = trailerUrl,
        _url = url;

  // Public read-only accessors (encapsulation)
  int get malId => _malId;
  String get title => _title;
  String get imageUrl => _imageUrl;
  String? get synopsis => _synopsis;
  double? get score => _score;
  int? get rank => _rank;
  int? get popularity => _popularity;
  int? get members => _members;
  String? get type => _type;
  String? get status => _status;
  int? get year => _year;
  String? get rating => _rating;
  String? get duration => _duration;
  List<String> get studios => List.unmodifiable(_studios);
  List<String> get genres => List.unmodifiable(_genres);
  String? get trailerUrl => _trailerUrl;
  String? get url => _url;

  // Polymorphic property: subclasses identify their kind.
  String get mediaKind;

  // Derived helper methods (behavior)
  bool get hasTrailer => _trailerUrl != null && _trailerUrl!.isNotEmpty;
  String get shortSynopsis => (_synopsis ?? '').length > 160
      ? _synopsis!.substring(0, 157) + '...'
      : (_synopsis ?? '');

  /// Engagement score (example polymorphic behavior). Subclasses can override.
  double engagementScore() {
    final pop = _popularity ?? 0;
    final mem = _members ?? 0;
    final base = (pop + mem) / 2.0;
    final quality = (_score ?? 0) * 1000;
    return base + quality; // naive formula
  }

  /// Convert to JSON (subclasses may extend this map).
  Map<String, dynamic> toJson() => {
        'mal_id': _malId,
        'title': _title,
        'image_url': _imageUrl,
        'synopsis': _synopsis,
        'score': _score,
        'rank': _rank,
        'popularity': _popularity,
        'members': _members,
        'type': _type,
        'status': _status,
        'year': _year,
        'rating': _rating,
        'duration': _duration,
        'studios': _studios,
        'genres': _genres,
        'trailer_url': _trailerUrl,
        'url': _url,
        'media_kind': mediaKind,
      };
}
