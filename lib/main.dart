import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/network/network_info.dart';
import 'core/utils/app_prefs.dart';
import 'data/datasources/local/authentication_local_datasource.dart';
import 'data/datasources/remote/anime_remote_datasource.dart';
import 'data/repositories/anime_repository_impl.dart';
import 'data/repositories/authentication_repository_impl.dart';
import 'domain/repositories/anime_repository.dart';
import 'domain/repositories/authentication_repository.dart';
import 'domain/usecases/get_top_anime.dart';
import 'domain/usecases/get_anime_details.dart';
import 'domain/usecases/search_anime.dart';
import 'domain/usecases/login_user.dart';
import 'domain/usecases/register_user.dart';
import 'domain/usecases/get_current_user.dart';
import 'domain/usecases/logout_user.dart';

// UBAH: Import Cubit, bukan Bloc
import 'presentation/blocs/anime/anime_cubit.dart';
import 'presentation/blocs/authentication/authentication_cubit.dart';
import 'presentation/blocs/splash/splash_cubit.dart';

final sl = ServiceLocator();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Global error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  await sl.init();

  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        // UBAH: Gunakan Cubit di sini
        return MultiBlocProvider(
          providers: [
            BlocProvider<SplashCubit>(
              create: (context) => sl<SplashCubit>(),
            ),
            BlocProvider<AuthenticationCubit>(
              // Panggil function checkAuthStatus() dari Cubit
              create: (context) => sl<AuthenticationCubit>()..checkAuthStatus(),
            ),
            BlocProvider<AnimeCubit>(
              create: (context) => sl<AnimeCubit>(),
            ),
          ],
          child: MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: Colors.blue[900],
              useMaterial3: true,
            ),
          ),
        );
      },
    );
  }
}

class ServiceLocator {
  late Dio _dio;
  late SharedPreferences _sharedPreferences;
  late NetworkInfo _networkInfo;
  late AppPreferences _appPreferences;

  // Data Sources
  late AnimeRemoteDataSource _animeRemoteDataSource;
  late AuthenticationLocalDataSource _authenticationLocalDataSource;

  // Repositories
  late AnimeRepository _animeRepository;
  late AuthenticationRepository _authenticationRepository;

  // Use Cases
  late GetTopAnime _getTopAnime;
  late GetAnimeDetails _getAnimeDetails;
  late SearchAnime _searchAnime;
  late LoginUser _loginUser;
  late RegisterUser _registerUser;
  late GetCurrentUser _getCurrentUser;
  late LogoutUser _logoutUser;

  Future<void> init() async {
    // External
    _dio = Dio();
    _sharedPreferences = await SharedPreferences.getInstance();

    // Core
    _networkInfo = NetworkInfoImpl(_dio);
    _appPreferences = AppPreferences(_sharedPreferences);

    // Data Sources
    _animeRemoteDataSource = AnimeRemoteDataSourceImpl(dio: _dio);
    _authenticationLocalDataSource = AuthenticationLocalDataSourceImpl(
      sharedPreferences: _sharedPreferences,
    );

    // Repositories
    _animeRepository = AnimeRepositoryImpl(
      remoteDataSource: _animeRemoteDataSource,
      networkInfo: _networkInfo,
    );
    _authenticationRepository = AuthenticationRepositoryImpl(
      localDataSource: _authenticationLocalDataSource,
      appPreferences: _appPreferences,
    );

    // Use Cases
    _getTopAnime = GetTopAnime(_animeRepository);
    _getAnimeDetails = GetAnimeDetails(_animeRepository);
    _searchAnime = SearchAnime(_animeRepository);
    _loginUser = LoginUser(_authenticationRepository);
    _registerUser = RegisterUser(_authenticationRepository);
    _getCurrentUser = GetCurrentUser(_authenticationRepository);
    _logoutUser = LogoutUser(_authenticationRepository);
  }

  T call<T>() {
    // Registrasi Cubit
    if (T == SplashCubit) {
      return SplashCubit(getCurrentUser: _getCurrentUser) as T;
    }
    if (T == AuthenticationCubit) {
      return AuthenticationCubit(
        loginUser: _loginUser,
        registerUser: _registerUser,
        getCurrentUser: _getCurrentUser,
        logoutUser: _logoutUser,
      ) as T;
    }
    if (T == AnimeCubit) {
      return AnimeCubit(
        getTopAnime: _getTopAnime,
        getAnimeDetails: _getAnimeDetails,
        searchAnime: _searchAnime,
      ) as T;
    }

    // Registrasi dependensi lainnya
    switch (T) {
      case Dio: return _dio as T;
      case SharedPreferences: return _sharedPreferences as T;
      case NetworkInfo: return _networkInfo as T;
      case AppPreferences: return _appPreferences as T;
      case AnimeRemoteDataSource: return _animeRemoteDataSource as T;
      case AuthenticationLocalDataSource: return _authenticationLocalDataSource as T;
      case AnimeRepository: return _animeRepository as T;
      case AuthenticationRepository: return _authenticationRepository as T;
      case GetTopAnime: return _getTopAnime as T;
      case GetAnimeDetails: return _getAnimeDetails as T;
      case SearchAnime: return _searchAnime as T;
      case LoginUser: return _loginUser as T;
      case RegisterUser: return _registerUser as T;
      case GetCurrentUser: return _getCurrentUser as T;
      case LogoutUser: return _logoutUser as T;
      default: throw Exception('Service not found for type $T');
    }
  }
}