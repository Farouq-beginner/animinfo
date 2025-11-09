part of 'anime_bloc.dart';

abstract class AnimeState extends Equatable {
  const AnimeState();

  @override
  List<Object> get props => [];
}

class AnimeInitial extends AnimeState {}

class AnimeLoading extends AnimeState {}

class TopAnimeLoaded extends AnimeState {
  final List<Anime> animeList;

  const TopAnimeLoaded(this.animeList);

  @override
  List<Object> get props => [animeList];
}

class AnimeDetailsLoaded extends AnimeState {
  final Anime anime;

  const AnimeDetailsLoaded(this.anime);

  @override
  List<Object> get props => [anime];
}

class SearchAnimeLoaded extends AnimeState {
  final List<Anime> animeList;

  const SearchAnimeLoaded(this.animeList);

  @override
  List<Object> get props => [animeList];
}

class AnimeError extends AnimeState {
  final String message;

  const AnimeError(this.message);

  @override
  List<Object> get props => [message];
}