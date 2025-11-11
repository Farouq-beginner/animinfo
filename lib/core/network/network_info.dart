import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/api_constants.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Dio dio;

  NetworkInfoImpl(this.dio);

  @override
  Future<bool> get isConnected async {
    try {
      // On web, calling arbitrary domains (like google.com) is blocked by CORS.
      // Probe the actual API base instead, which provides proper CORS headers.
      final String url = kIsWeb
          ? '${ApiConstants.baseUrl}${ApiConstants.topAnimeEndpoint}'
          : 'https://www.google.com';

      final response = await dio.get(url,
          queryParameters: kIsWeb ? {'limit': 1} : null,
          options: Options(
            // Short timeouts so we don't block UI long.
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}