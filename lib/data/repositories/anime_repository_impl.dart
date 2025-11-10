import 'package:api_anime/core/errors/exceptions.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/anime.dart';
import '../../domain/repositories/anime_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote/anime_remote_datasource.dart';

class AnimeRepositoryImpl implements AnimeRepository {
  final AnimeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AnimeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Anime>>> getTopAnime() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAnime = await remoteDataSource.getTopAnime();
        // Convert models to entities
        final animeEntities = remoteAnime.map((model) => model.toDomain()).toList();
        return Right(animeEntities);
      } on ServerException {
        return Left(ServerFailure('Failed to get top anime'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Anime>> getAnimeDetails(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAnime = await remoteDataSource.getAnimeDetails(id);
        // Convert model to entity
        return Right(remoteAnime.toDomain());
      } on ServerException {
        return Left(ServerFailure('Failed to get anime details'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Anime>>> searchAnime(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAnime = await remoteDataSource.searchAnime(query);
        // Convert models to entities
        final animeEntities = remoteAnime.map((model) => model.toDomain()).toList();
        return Right(animeEntities);
      } on ServerException {
        return Left(ServerFailure('Failed to search anime'));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}