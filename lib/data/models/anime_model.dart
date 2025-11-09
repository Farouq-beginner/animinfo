// IMPOR MODEL, BUKAN ENTITY
import 'genre_model.dart';
import 'producer_model.dart';
import '../../domain/entities/anime.dart';

class AnimeModel {
  final int malId;
  final String url;
  final Map<String, dynamic> images;
  final String imageUrl; // Ini akan kita isi dengan benar
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final List<String>? titleSynonyms;
  final String? type;
  final String? source;
  final int? episodes;
  final String? status;
  final bool? airing;
  final String? aired;
  final String? duration;
  final String? rating;
  final double? score;
  final int? scoredBy;
  final int? rank;
  final int? popularity;
  final int? members;
  final int? favorites;
  final String? synopsis;
  final String? background;
  final String? season;
  final int? year;
  final Map<String, dynamic>? broadcast;

  // GUNAKAN MODEL, BUKAN ENTITY
  final List<GenreModel>? genres;
  final List<ProducerModel>? producers;
  final List<ProducerModel>? licensors;
  final List<ProducerModel>? studios;

  AnimeModel({
    required this.malId,
    required this.url,
    required this.images,
    required this.imageUrl,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    this.titleSynonyms,
    this.type,
    this.source,
    this.episodes,
    this.status,
    this.airing,
    this.aired,
    this.duration,
    this.rating,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    this.members,
    this.favorites,
    this.synopsis,
    this.background,
    this.season,
    this.year,
    this.broadcast,
    this.genres,
    this.producers,
    this.licensors,
    this.studios,
  });

  // HAPUS try-catch yang bermasalah. Biarkan loop di AnimeResponse yang menanganinya.
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    // 1. Logika ParsiSng Gambar yang Aman
    String imageUrl = '';
    if (json['images'] != null && json['images'] is Map) {
      if (json['images']['jpg'] != null && json['images']['jpg']['image_url'] != null) {
        imageUrl = json['images']['jpg']['image_url'];
      } else if (json['images']['webp'] != null && json['images']['webp']['image_url'] != null) {
        imageUrl = json['images']['webp']['image_url'];
      }
    }
    // Fallback jika format di atas gagal
    if (imageUrl.isEmpty && json['image_url'] != null) {
      imageUrl = json['image_url'];
    }

    // 2. Logika Parsing List (Helper)
    List<T> _parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      if (json[key] != null && json[key] is List) {
        return (json[key] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    // 3. Buat modelnya
    return AnimeModel(
      malId: json['mal_id'] ?? 0,
      url: json['url'] ?? '',
      images: json['images'] ?? {},
      imageUrl: imageUrl, // Gunakan imageUrl yang sudah diparsing
      title: json['title'] ?? 'Unknown Title',
      titleEnglish: json['title_english'],
      titleJapanese: json['title_japanese'],
      titleSynonyms: (json['title_synonyms'] as List?)?.map((e) => e.toString()).toList(),
      type: json['type'],
      source: json['source'],
      episodes: json['episodes'],
      status: json['status'],
      airing: json['airing'],
      aired: json['aired']?['string'], // Ambil string tanggal
      duration: json['duration'],
      rating: json['rating'],
      score: (json['score'] as num?)?.toDouble(), // Konversi num ke double
      scoredBy: (json['scored_by'] as num?)?.toInt(),
      rank: (json['rank'] as num?)?.toInt(),
      popularity: (json['popularity'] as num?)?.toInt(),
      members: (json['members'] as num?)?.toInt(),
      favorites: (json['favorites'] as num?)?.toInt(),
      synopsis: json['synopsis'],
      background: json['background'],
      season: json['season'],
      year: (json['year'] as num?)?.toInt(),
      broadcast: json['broadcast'],
      // Gunakan helper parsing list
      genres: _parseList('genres', (g) => GenreModel.fromJson(g)),
      producers: _parseList('producers', (p) => ProducerModel.fromJson(p)),
      licensors: _parseList('licensors', (l) => ProducerModel.fromJson(l)),
      studios: _parseList('studios', (s) => ProducerModel.fromJson(s)),
    );
  }

  // Convert to domain entity
  Anime toDomain() {
    return Anime(
      malId: malId,
      url: url,
      images: images,
      imageUrl: imageUrl,
      title: title,
      titleEnglish: titleEnglish,
      titleJapanese: titleJapanese,
      titleSynonyms: titleSynonyms,
      type: type,
      source: source,
      episodes: episodes,
      status: status,
      airing: airing,
      aired: aired,
      duration: duration,
      rating: rating,
      score: score,
      scoredBy: scoredBy,
      rank: rank,
      popularity: popularity,
      members: members,
      favorites: favorites,
      synopsis: synopsis,
      background: background,
      season: season,
      year: year,
      broadcast: broadcast,
      // KONVERSI LIST DARI MODEL KE ENTITY
      genres: genres?.map((model) => model.toDomain()).toList(),
      producers: producers?.map((model) => model.toDomain()).toList(),
      licensors: licensors?.map((model) => model.toDomain()).toList(),
      studios: studios?.map((model) => model.toDomain()).toList(),
    );
  }

  // toJson (Tidak wajib, tapi bagus untuk ada)
  Map<String, dynamic> toJson() {
    return {
      'mal_id': malId,
      'url': url,
      'images': images,
      'title': title,
      'type': type,
      'episodes': episodes,
      'score': score,
      'synopsis': synopsis,
      'genres': genres?.map((g) => g.toJson()).toList(),
      'producers': producers?.map((p) => p.toJson()).toList(),
      'licensors': licensors?.map((l) => l.toJson()).toList(),
      'studios': studios?.map((s) => s.toJson()).toList(),
    };
  }
}

// =======================================================
// KELAS RESPONSE (Biarkan di file yang sama)
// =======================================================

class AnimeResponse {
  final List<AnimeModel> data;
  final Pagination pagination;

  AnimeResponse({
    required this.data,
    required this.pagination,
  });

  factory AnimeResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('📄 Parsing AnimeResponse from JSON');
      final data = <AnimeModel>[];

      if (json['data'] != null && json['data'] is List) {
        final dataList = json['data'] as List;
        print('📄 Processing ${dataList.length} items in data array');

        for (int i = 0; i < dataList.length; i++) {
          try {
            // Kita panggil AnimeModel.fromJson di sini
            final anime = AnimeModel.fromJson(dataList[i]);
            data.add(anime);
          } catch (e) {
            // Jika SATU anime gagal parsing, kita lewati & log
            print('⚠️ Error parsing anime at index $i: $e');
          }
        }
      } else {
        print('⚠️ No data field or invalid data field in response');
      }

      final pagination = Pagination.fromJson(json['pagination'] ?? {});

      print('✅ Successfully parsed AnimeResponse with ${data.length} anime');
      return AnimeResponse(
        data: data,
        pagination: pagination,
      );
    } catch (e) {
      print('❌ Error parsing AnimeResponse: $e');
      return AnimeResponse(
        data: [],
        pagination: Pagination(hasNextPage: false, currentPage: 1),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((anime) => anime.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class Pagination {
  final bool hasNextPage;
  final int currentPage;

  Pagination({
    required this.hasNextPage,
    required this.currentPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    try {
      return Pagination(
        hasNextPage: json['has_next_page'] ?? false,
        currentPage: json['current_page'] ?? 1,
      );
    } catch (e) {
      print('⚠️ Error parsing Pagination: $e');
      return Pagination(hasNextPage: false, currentPage: 1);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'has_next_page': hasNextPage,
      'current_page': currentPage,
    };
  }
}