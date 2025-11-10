import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/anime.dart';
import '../repositories/anime_repository.dart';
import '../../core/errors/failures.dart';

class SearchAnime implements UseCase<List<Anime>, String> {
  final AnimeRepository repository;

  SearchAnime(this.repository);

  @override
  Future<Either<Failure, List<Anime>>> call(String params) async {
    return await repository.searchAnime(params);
  }
}