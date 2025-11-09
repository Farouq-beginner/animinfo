import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/logout_user.dart';
import '../../../domain/usecases/register_user.dart';
import '../../../core/errors/failures.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;

  AuthenticationBloc({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
    required this.logoutUser,
  }) : super(AuthenticationInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(
      LoginEvent event,
      Emitter<AuthenticationState> emit,
      ) async {
    emit(AuthenticationLoading());
    final params = LoginParams(
      email: event.email,
      password: event.password,
    );
    final result = await loginUser(params);
    result.fold(
          (failure) => emit(AuthenticationError(failure.message)),
          (user) => emit(AuthenticationAuthenticated(user)),
    );
  }

  Future<void> _onRegister(
      RegisterEvent event,
      Emitter<AuthenticationState> emit,
      ) async {
    emit(AuthenticationLoading());
    final params = RegisterParams(
      username: event.username,
      email: event.email,
      password: event.password,
    );
    final result = await registerUser(params);
    result.fold(
          (failure) => emit(AuthenticationError(failure.message)),
          (user) => emit(AuthenticationAuthenticated(user)),
    );
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthenticationState> emit,
      ) async {
    emit(AuthenticationLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(AuthenticationUnauthenticated()),
          (user) => emit(AuthenticationAuthenticated(user)),
    );
  }

  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<AuthenticationState> emit,
      ) async {
    emit(AuthenticationLoading());
    final result = await logoutUser(NoParams());
    result.fold(
          (failure) => emit(AuthenticationError(failure.message)),
          (_) => emit(AuthenticationUnauthenticated()),
    );
  }
}