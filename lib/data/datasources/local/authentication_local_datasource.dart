import 'dart:convert';
import 'package:api_anime/data/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/exceptions.dart';

abstract class AuthenticationLocalDataSource {
  Future<void> cacheUser(AuthModel user);
  Future<AuthModel?> getUser();
  Future<void> removeUser();
}

class AuthenticationLocalDataSourceImpl implements AuthenticationLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthenticationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(AuthModel user) async {
    try {
      await sharedPreferences.setString(
        'CACHED_USER',
        jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<AuthModel?> getUser() async {
    try {
      final jsonString = sharedPreferences.getString('CACHED_USER');
      if (jsonString != null) {
        return AuthModel.fromJson(jsonDecode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> removeUser() async {
    try {
      await sharedPreferences.remove('CACHED_USER');
    } catch (e) {
      throw CacheException('Failed to remove cached user');
    }
  }
}