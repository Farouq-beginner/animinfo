import 'package:api_anime/domain/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart'; // IMPORT PERMISSION HANDLER
import '../../../domain/usecases/get_current_user.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final GetCurrentUser _getCurrentUser;

  SplashCubit({required GetCurrentUser getCurrentUser})
      : _getCurrentUser = getCurrentUser,
        super(SplashInitial());

  Future<void> checkLoginStatus() async {
    emit(SplashLoading());

    // --- REQUIREMENT 11: PERMISSION HANDLER ---
    // Meminta izin notifikasi.
    // Pada Android 13+, ini akan memunculkan dialog sistem.
    // Pada versi lama, ini akan otomatis granted.
    final status = await Permission.notification.status;
    if (status.isDenied || status.isProvisional) {
      await Permission.notification.request();
    }
    // ------------------------------------------

    // Tunggu sebentar untuk efek splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Cek status login user
    final result = await _getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(SplashUnauthenticated()),
          (user) => emit(SplashAuthenticated()),
    );
  }
}