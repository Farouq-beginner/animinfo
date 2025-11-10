import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AppPreferences {
  final SharedPreferences _prefs;

  AppPreferences(this._prefs);

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(userData));
  }

  Map<String, dynamic>? getUser() {
    final userString = _prefs.getString(AppConstants.userKey);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  Future<void> saveFavorite(int animeId) async {
    final favorites = getFavorites();
    favorites.add(animeId);
    await _prefs.setStringList(AppConstants.favoritesKey,
        favorites.map((id) => id.toString()).toList());
  }

  Future<void> removeFavorite(int animeId) async {
    final favorites = getFavorites();
    favorites.remove(animeId);
    await _prefs.setStringList(AppConstants.favoritesKey,
        favorites.map((id) => id.toString()).toList());
  }

  List<int> getFavorites() {
    final favoritesString = _prefs.getStringList(AppConstants.favoritesKey);
    if (favoritesString != null) {
      return favoritesString.map((id) => int.parse(id)).toList();
    }
    return [];
  }

  bool isFavorite(int animeId) {
    return getFavorites().contains(animeId);
  }
}