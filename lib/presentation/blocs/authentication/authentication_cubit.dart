import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/logout_user.dart';
import '../../../domain/usecases/register_user.dart';
import 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;

  AuthenticationCubit({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required GetCurrentUser getCurrentUser,
    required LogoutUser logoutUser,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _getCurrentUser = getCurrentUser,
        _logoutUser = logoutUser,
        super(AuthenticationInitial());

  Future<void> login(String email, String password) async {
    emit(AuthenticationLoading());
    final result = await _loginUser(LoginParams(email: email, password: password));
    result.fold(
          (failure) => emit(AuthenticationError(failure.message)),
          (user) => emit(AuthenticationAuthenticated(user)),
    );
  }

  Future<void> register(String username, String email, String password) async {
    emit(AuthenticationLoading());
    final result = await _registerUser(RegisterParams(username: username, email: email, password: password));
    result.fold(
          (failure) => emit(AuthenticationError(failure.message)),
          (user) => emit(AuthenticationAuthenticated(user)),
    );
  }

  Future<void> checkAuthStatus() async {
    emit(AuthenticationLoading());
    final result = await _getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(AuthenticationUnauthenticated()),
          (user) => emit(AuthenticationAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(AuthenticationLoading());
    final result = await _logoutUser(NoParams());
    result.fold(
          (failure) => emit(AuthenticationError(failure.message)),
          (_) => emit(AuthenticationUnauthenticated()),
    );
  }
}