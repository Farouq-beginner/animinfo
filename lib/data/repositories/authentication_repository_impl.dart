import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_prefs.dart';
import '../datasources/local/authentication_local_datasource.dart';
import '../models/auth_model.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationLocalDataSource localDataSource;
  final AppPreferences appPreferences;

  AuthenticationRepositoryImpl({
    required this.localDataSource,
    required this.appPreferences,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userData = appPreferences.getUser();
      if (userData != null && userData['email'] == email && userData['password'] == password) {
        final user = AuthModel.fromJson(userData);
        await localDataSource.cacheUser(user);
        return Right(user);
      } else {
        return Left(ServerFailure('Invalid email or password'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to login'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String username, String email, String password) async {
    try {
      final userData = appPreferences.getUser();
      if (userData != null && userData['email'] == email) {
        return Left(ServerFailure('Email already exists'));
      }

      final newUser = AuthModel(
        id: DateTime.now().millisecondsSinceEpoch,
        username: username,
        email: email,
        password: password,
      );

      await appPreferences.saveUser(newUser.toJson());
      await localDataSource.cacheUser(newUser);
      return Right(newUser);
    } catch (e) {
      return Left(CacheFailure('Failed to register'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        return Right(user);
      } else {
        return Left(CacheFailure('No user found'));
      }
    } catch (e) {
      return Left(CacheFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.removeUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout'));
    }
  }
}