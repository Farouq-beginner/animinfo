import 'package:dartz/dartz.dart';
import '../entities/anime.dart';
import '../../core/errors/failures.dart';

abstract class AnimeRepository {
  Future<Either<Failure, List<Anime>>> getTopAnime();
  Future<Either<Failure, Anime>> getAnimeDetails(int id);
  Future<Either<Failure, List<Anime>>> searchAnime(String query);
}