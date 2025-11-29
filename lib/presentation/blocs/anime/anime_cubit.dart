import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_anime/domain/usecases/usecase.dart';
import '../../../domain/entities/anime.dart';
import '../../../domain/usecases/get_anime_details.dart';
import '../../../domain/usecases/get_top_anime.dart';
import '../../../domain/usecases/search_anime.dart';
import 'anime_state.dart';

class AnimeCubit extends Cubit<AnimeState> {
  final GetTopAnime _getTopAnime;
  final GetAnimeDetails _getAnimeDetails;
  final SearchAnime _searchAnime;

  // Simpan data asli untuk keperluan filter/reset
  List<Anime> _originalList = [];

  AnimeCubit({
    required GetTopAnime getTopAnime,
    required GetAnimeDetails getAnimeDetails,
    required SearchAnime searchAnime,
  })  : _getTopAnime = getTopAnime,
        _getAnimeDetails = getAnimeDetails,
        _searchAnime = searchAnime,
        super(AnimeInitial());

  Future<void> getTopAnime() async {
    try {
      emit(AnimeLoading());
      final result = await _getTopAnime(NoParams());

      result.fold(
            (failure) => emit(AnimeError(failure.message)),
            (animeList) {
          // Simpan list asli saat pertama kali fetch berhasil
          _originalList = animeList;
          emit(TopAnimeLoaded(animeList));
        },
      );
    } catch (e) {
      emit(AnimeError('Unexpected error: $e'));
    }
  }

  Future<void> getAnimeDetails(int id) async {
    try {
      emit(AnimeLoading());
      final result = await _getAnimeDetails(id);

      result.fold(
            (failure) => emit(AnimeError(failure.message)),
            (anime) => emit(AnimeDetailsLoaded(anime)),
      );
    } catch (e) {
      emit(AnimeError('Unexpected error: $e'));
    }
  }

  Future<void> searchAnime(String query) async {
    try {
      emit(AnimeLoading());
      final result = await _searchAnime(query);

      result.fold(
            (failure) => emit(AnimeError(failure.message)),
            (animeList) => emit(SearchAnimeLoaded(animeList)),
      );
    } catch (e) {
      emit(AnimeError('Unexpected error: $e'));
    }
  }

  // --- FITUR FILTER & SORTING (PERBAIKAN TIPE DATA) ---
  void applyFilterAndSort({
    String genre = 'All',
    String studio = 'All',
    String status = 'All',
    String sortBy = 'Score High-Low',
  }) {
    // Selalu mulai dari data asli agar filter tidak destruktif
    List<Anime> filteredList = List.from(_originalList);

    // 1. Filter Genre
    if (genre != 'All') {
      filteredList = filteredList.where((anime) {
        // PERBAIKAN: Handle null dan akses .name
        final genres = anime.genres ?? [];
        return genres.any((g) => g.name.toLowerCase() == genre.toLowerCase());
      }).toList();
    }

    // 2. Filter Studio
    if (studio != 'All') {
      filteredList = filteredList.where((anime) {
        // PERBAIKAN: Handle null dan akses .name
        final studios = anime.studios ?? [];
        return studios.any((s) => s.name.toLowerCase() == studio.toLowerCase());
      }).toList();
    }

    // 3. Filter Status
    if (status != 'All') {
      filteredList = filteredList.where((anime) {
        return (anime.status ?? '').toLowerCase() == status.toLowerCase();
      }).toList();
    }

    // 4. Sorting
    switch (sortBy) {
      case 'Score High-Low':
        filteredList.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
        break;
      case 'Score Low-High':
        filteredList.sort((a, b) => (a.score ?? 0).compareTo(b.score ?? 0));
        break;
      case 'Title A-Z':
        filteredList.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    // Emit state baru dengan data hasil filter
    emit(TopAnimeLoaded(filteredList));
  }
}