import 'package:api_anime/data/models/anime_model.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';

abstract class AnimeRemoteDataSource {
  Future<List<AnimeModel>> getTopAnime();
  Future<AnimeModel> getAnimeDetails(int id);
  Future<List<AnimeModel>> searchAnime(String query);
}

class AnimeRemoteDataSourceImpl implements AnimeRemoteDataSource {
  final Dio dio;

  AnimeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AnimeModel>> getTopAnime() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.topAnimeEndpoint}';
      print('🔍 Making API call to: $url');

      final response = await dio.get(url);
      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('📄 Response data keys: ${response.data.keys}');

        if (response.data['data'] != null) {
          print('📊 Data array length: ${(response.data['data'] as List).length}');

          final animeResponse = AnimeResponse.fromJson(response.data);
          print('✅ Parsed ${animeResponse.data.length} anime from response');

          // Log first anime for debugging
          if (animeResponse.data.isNotEmpty) {
            final firstAnime = animeResponse.data.first;
            print('🎌 First anime: ${firstAnime.title} (ID: ${firstAnime.malId})');
          }

          return animeResponse.data;
        } else {
          print('❌ No data field in response');
          throw ServerException('No data field in API response');
        }
      } else {
        print('❌ API call failed with status: ${response.statusCode}');
        throw ServerException('Failed to load top anime. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ DioException type: ${e.type}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
      }
      throw ServerException('Network error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AnimeModel> getAnimeDetails(int id) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.animeDetailsEndpoint}/$id';
      print('🔍 Making API call to: $url');

      final response = await dio.get(url);
      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AnimeModel.fromJson(response.data['data']);
      } else {
        throw ServerException('Failed to load anime details. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw ServerException('Network error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<AnimeModel>> searchAnime(String query) async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.searchAnimeEndpoint}';
      print('🔍 Making API call to: $url?q=$query');

      final response = await dio.get(
        url,
        queryParameters: {'q': query},
      );
      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final animeResponse = AnimeResponse.fromJson(response.data);
        print('✅ Found ${animeResponse.data.length} anime for query: $query');
        return animeResponse.data;
      } else {
        throw ServerException('Failed to search anime. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw ServerException('Network error: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  Future<void> testApiResponse() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.topAnimeEndpoint}';
      print('🧪 Testing API response from: $url');

      final response = await dio.get(url);
      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final firstAnime = response.data['data'][0];
        print('🧪 First anime data:');
        print('   Title: ${firstAnime['title']}');
        print('   Image URL: ${firstAnime['images']?['jpg']?['image_url'] ?? 'Not found'}');
        print('   Synopsis: ${firstAnime['synopsis']?.substring(0, 100) ?? 'Not found'}...');
      }
    } catch (e) {
      print('❌ API test error: $e');
    }
  }
}