import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/anime.dart';
import '../../../domain/usecases/get_anime_details.dart';
import '../../../domain/usecases/get_top_anime.dart';
import '../../../domain/usecases/search_anime.dart';
import '../../../core/errors/failures.dart';

part 'anime_event.dart';
part 'anime_state.dart';

class AnimeBloc extends Bloc<AnimeEvent, AnimeState> {
  final GetTopAnime getTopAnime;
  final GetAnimeDetails getAnimeDetails;
  final SearchAnime searchAnime;

  AnimeBloc({
    required this.getTopAnime,
    required this.getAnimeDetails,
    required this.searchAnime,
  }) : super(AnimeInitial()) {
    on<GetTopAnimeEvent>(_onGetTopAnime);
    on<GetAnimeDetailsEvent>(_onGetAnimeDetails);
    on<SearchAnimeEvent>(_onSearchAnime);
  }

  Future<void> _onGetTopAnime(
      GetTopAnimeEvent event,
      Emitter<AnimeState> emit,
      ) async {
    try {
      print('🎬 AnimeBloc: Processing GetTopAnimeEvent');
      emit(AnimeLoading());

      final result = await getTopAnime(NoParams());

      result.fold(
            (failure) {
          print('❌ AnimeBloc: Error getting top anime - ${failure.message}');
          emit(AnimeError(failure.message));
        },
            (animeList) {
          print('✅ AnimeBloc: Successfully loaded ${animeList.length} anime');
          if (animeList.isEmpty) {
            print('⚠️ AnimeBloc: Anime list is empty');
          } else {
            print('🎌 AnimeBloc: First anime: ${animeList.first.title}');
          }
          emit(TopAnimeLoaded(animeList));
        },
      );
    } catch (e) {
      print('❌ AnimeBloc: Unexpected error in _onGetTopAnime: $e');
      emit(AnimeError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onGetAnimeDetails(
      GetAnimeDetailsEvent event,
      Emitter<AnimeState> emit,
      ) async {
    try {
      print('🎬 AnimeBloc: Processing GetAnimeDetailsEvent for ID ${event.animeId}');
      emit(AnimeLoading());

      final result = await getAnimeDetails(event.animeId);

      result.fold(
            (failure) {
          print('❌ AnimeBloc: Error getting anime details - ${failure.message}');
          emit(AnimeError(failure.message));
        },
            (anime) {
          print('✅ AnimeBloc: Successfully loaded anime details for ${anime.title}');
          emit(AnimeDetailsLoaded(anime));
        },
      );
    } catch (e) {
      print('❌ AnimeBloc: Unexpected error in _onGetAnimeDetails: $e');
      emit(AnimeError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onSearchAnime(
      SearchAnimeEvent event,
      Emitter<AnimeState> emit,
      ) async {
    try {
      print('🎬 AnimeBloc: Processing SearchAnimeEvent for query "${event.query}"');
      emit(AnimeLoading());

      final result = await searchAnime(event.query);

      result.fold(
            (failure) {
          print('❌ AnimeBloc: Error searching anime - ${failure.message}');
          emit(AnimeError(failure.message));
        },
            (animeList) {
          print('✅ AnimeBloc: Successfully found ${animeList.length} anime');
          emit(SearchAnimeLoaded(animeList));
        },
      );
    } catch (e) {
      print('❌ AnimeBloc: Unexpected error in _onSearchAnime: $e');
      emit(AnimeError('An unexpected error occurred: $e'));
    }
  }
}