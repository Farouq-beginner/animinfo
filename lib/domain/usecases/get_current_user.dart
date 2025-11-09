import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';
import '../../core/errors/failures.dart';

class GetCurrentUser implements UseCase<User, NoParams> {
  final AuthenticationRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}