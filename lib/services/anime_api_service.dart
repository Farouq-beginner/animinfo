import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../models/anime.dart';
import '../models/anime_page.dart';

/// API client for Jikan v4 (https://api.jikan.moe/v4)
class AnimeApiService {
  final Dio _dio;

  AnimeApiService({
    Duration connectTimeout = const Duration(seconds: 20),
    Duration receiveTimeout = const Duration(seconds: 20),
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.jikan.moe/v4',
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: connectTimeout,
            validateStatus: (code) => code != null && code >= 200 && code < 300,
          ),
        );

  Future<List<Anime>> fetchAnimeList({int page = 1}) async {
    final res = await _getWithRetry('/anime', queryParameters: {'page': page});
    final data = res.data['data'] as List<dynamic>;
    return data.map((json) => Anime.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Anime> fetchAnimeDetail(int malId) async {
    final res = await _getWithRetry('/anime/$malId');
    final json = res.data['data'] as Map<String, dynamic>;
    return Anime.fromJson(json);
  }

  /// Flexible fetch with most of Jikan /anime query parameters supported.
  /// Only non-null parameters are sent.
  Future<AnimePage> fetchAnimePage({
    int page = 1,
    int? limit,
    String? q,
    String? type, // tv, movie, ova, special, ona, music, unknown
    String? status, // airing, complete, upcoming
    String? rating, // g, pg, pg13, r17, r, rx
    bool? sfw,
    String? orderBy, // score, rank, popularity, favorites, title, start_date, episodes, etc.
    String? sort, // asc, desc
    String? letter,
    String? startDate, // YYYY-MM-DD
    String? endDate, // YYYY-MM-DD
    List<int>? genres, // genre ids CSV
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      if (limit != null) 'limit': limit,
      if (q != null && q.isNotEmpty) 'q': q,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (sfw != null) 'sfw': sfw,
      if (orderBy != null) 'order_by': orderBy,
      if (sort != null) 'sort': sort,
      if (letter != null && letter.isNotEmpty) 'letter': letter,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (genres != null && genres.isNotEmpty) 'genres': genres.join(','),
    };

    final res = await _getWithRetry('/anime', queryParameters: qp);
    final list = (res.data['data'] as List<dynamic>)
        .map((e) => Anime.fromJson(e as Map<String, dynamic>))
        .toList();
    final hasNext = res.data['pagination']?['has_next_page'] == true;
    final currentPage = res.data['pagination']?['current_page'] as int?;
    return AnimePage(data: list, hasNextPage: hasNext, currentPage: currentPage);
  }

  Future<Response<dynamic>> _getWithRetry(
    String path, {
    Map<String, dynamic>? queryParameters,
    int maxRetries = 3,
    Duration initialBackoff = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await _dio.get(path, queryParameters: queryParameters);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        // Jikan has rate limits; retry 429 and transient network/5xx errors
        final retryable =
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            status == 429 ||
            (status != null && status >= 500 && status < 600);

        if (!retryable || attempt >= maxRetries) {
          // Bubble a user-friendly message
          final message = status == 429
              ? 'Rate limit Jikan tercapai. Coba lagi beberapa saat.'
              : (e.message ?? 'Gagal memuat data dari server.');
          throw Exception(message);
        }

        // honor Retry-After header if provided (seconds)
        final retryAfter = e.response?.headers.value('retry-after');
        Duration delay;
        if (retryAfter != null) {
          final seconds = int.tryParse(retryAfter) ?? 0;
          delay = Duration(seconds: seconds.clamp(0, 60));
        } else {
          final ms = initialBackoff.inMilliseconds * math.pow(2, attempt).toInt();
          delay = Duration(milliseconds: ms);
        }
        await Future.delayed(delay);
        attempt++;
      }
    }
  }
}
