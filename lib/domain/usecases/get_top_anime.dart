import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/anime.dart';
import '../repositories/anime_repository.dart';
import '../../core/errors/failures.dart';

class GetTopAnime implements UseCase<List<Anime>, NoParams> {
  final AnimeRepository repository;

  GetTopAnime(this.repository);

  @override
  Future<Either<Failure, List<Anime>>> call(NoParams params) async {
    return await repository.getTopAnime();
  }
}