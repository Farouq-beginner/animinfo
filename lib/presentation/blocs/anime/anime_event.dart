part of 'anime_bloc.dart';

abstract class AnimeEvent extends Equatable {
  const AnimeEvent();

  @override
  List<Object> get props => [];
}

class GetTopAnimeEvent extends AnimeEvent {}

class GetAnimeDetailsEvent extends AnimeEvent {
  final int animeId;

  const GetAnimeDetailsEvent(this.animeId);

  @override
  List<Object> get props => [animeId];
}

class SearchAnimeEvent extends AnimeEvent {
  final String query;

  const SearchAnimeEvent(this.query);

  @override
  List<Object> get props => [query];
}