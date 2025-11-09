import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/anime.dart';
import '../repositories/anime_repository.dart';
import '../../core/errors/failures.dart';

class GetAnimeDetails implements UseCase<Anime, int> {
  final AnimeRepository repository;

  GetAnimeDetails(this.repository);

  @override
  Future<Either<Failure, Anime>> call(int params) async {
    return await repository.getAnimeDetails(params);
  }
}