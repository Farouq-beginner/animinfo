import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';
import '../../core/errors/failures.dart';

class LoginUser implements UseCase<User, LoginParams> {
  final AuthenticationRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}