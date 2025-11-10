import 'package:equatable/equatable.dart';
import 'genre.dart';
import 'producer.dart';

class Anime extends Equatable {
  final int malId;
  final String url;
  final Map<String, dynamic> images;
  final String imageUrl;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final List<String>? titleSynonyms;
  final String? type;
  final String? source;
  final int? episodes;
  final String? status;
  final bool? airing;
  final String? aired;
  final String? duration;
  final String? rating;
  final double? score;
  final int? scoredBy;
  final int? rank;
  final int? popularity;
  final int? members;
  final int? favorites;
  final String? synopsis;
  final String? background;
  final String? season;
  final int? year;
  final Map<String, dynamic>? broadcast;
  final List<Genre>? genres;
  final List<Producer>? producers;
  final List<Producer>? licensors;
  final List<Producer>? studios;

  const Anime({
    required this.malId,
    required this.url,
    required this.images,
    required this.imageUrl,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    this.titleSynonyms,
    this.type,
    this.source,
    this.episodes,
    this.status,
    this.airing,
    this.aired,
    this.duration,
    this.rating,
    this.score,
    this.scoredBy,
    this.rank,
    this.popularity,
    this.members,
    this.favorites,
    this.synopsis,
    this.background,
    this.season,
    this.year,
    this.broadcast,
    this.genres,
    this.producers,
    this.licensors,
    this.studios,
  });

  @override
  List<Object?> get props => [
    malId,
    url,
    images,
    imageUrl,
    title,
    titleEnglish,
    titleJapanese,
    titleSynonyms,
    type,
    source,
    episodes,
    status,
    airing,
    aired,
    duration,
    rating,
    score,
    scoredBy,
    rank,
    popularity,
    members,
    favorites,
    synopsis,
    background,
    season,
    year,
    broadcast,
    genres,
    producers,
    licensors,
    studios,
  ];
}