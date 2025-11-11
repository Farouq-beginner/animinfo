import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../core/errors/failures.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUser getCurrentUser;

  SplashBloc({required this.getCurrentUser}) : super(SplashInitial()) {
    on<CheckLoginStatusEvent>(_onCheckLoginStatus);
  }

  Future<void> _onCheckLoginStatus(
      CheckLoginStatusEvent event,
      Emitter<SplashState> emit,
      ) async {
    emit(SplashLoading());
    await Future.delayed(const Duration(seconds: 5));

    final result = await getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(SplashUnauthenticated()),
          (user) => emit(SplashAuthenticated()),
    );
  }
}