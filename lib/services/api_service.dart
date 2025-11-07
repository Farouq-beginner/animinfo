import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../models/course.dart';

/// Simple API client for the Course service with sane timeouts and retry.
class ApiService {
  final Dio _dio;

  /// Create an instance with configurable [baseUrl] and timeouts.
  ///
  /// Defaults:
  /// - connectTimeout: 30s
  /// - receiveTimeout: 30s
  ///
  /// Note for local development:
  /// - Android emulator -> use http://10.0.2.2:8000
  /// - iOS simulator/Desktop/Web -> use http://localhost:8000
  /// - Physical device -> use your machine's LAN IP (e.g. http://192.168.x.x:8000)
  ApiService({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) : _dio = Dio(
          BaseOptions(
            // Default to the provided LAN IP; override per environment if needed.
            baseUrl: baseUrl ?? 'http://192.168.0.114:8000',
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: connectTimeout,
            // Accept any 2xx as success
            validateStatus: (code) => code != null && code >= 200 && code < 300,
          ),
        );

  Future<List<Course>> getCourses() async {
    try {
      final response = await _getWithRetry('/courses');
      final data = response.data;
      if (data is List) {
        return data.map((e) => Course.fromJson(e)).toList();
      }
      throw Exception('Format respons tidak sesuai, expected List.');
    } on DioException catch (e) {
      // Tambahkan pesan yang lebih informatif untuk kasus timeout/koneksi
      final reason = switch (e.type) {
        DioExceptionType.connectionTimeout =>
            'Batas waktu koneksi habis. Server mungkin lambat atau tidak dapat dijangkau.',
        DioExceptionType.receiveTimeout =>
            'Batas waktu menerima data habis. Server mungkin lambat.',
        DioExceptionType.connectionError =>
            'Gagal terhubung ke server. Periksa koneksi internet atau baseUrl.',
        DioExceptionType.badResponse =>
            'Server mengembalikan kesalahan ${e.response?.statusCode}.',
        _ => e.message ?? 'Kesalahan tidak diketahui',
      };
      throw Exception(
          'Error koneksi: $reason\nTips: Pastikan server berjalan dan baseUrl sesuai lingkungan (lihat catatan pada ApiService).');
    }
  }

  /// GET helper with limited retries and exponential backoff for transient errors.
  Future<Response<dynamic>> _getWithRetry(
    String path, {
    Map<String, dynamic>? queryParameters,
    int maxRetries = 3,
    Duration initialBackoff = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await _dio.get(
          path,
          queryParameters: queryParameters,
        );
      } on DioException catch (e) {
        final shouldRetry = _isTransient(e) && attempt < maxRetries;
        if (!shouldRetry) rethrow;
        final delayMs = initialBackoff.inMilliseconds * math.pow(2, attempt).toInt();
        await Future.delayed(Duration(milliseconds: delayMs));
        attempt++;
      }
    }
  }

  bool _isTransient(DioException e) {
    final status = e.response?.statusCode ?? 0;
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (status >= 500 && status < 600);
  }
}
