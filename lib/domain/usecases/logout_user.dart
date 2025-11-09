import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../repositories/authentication_repository.dart';
import '../../core/errors/failures.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthenticationRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}