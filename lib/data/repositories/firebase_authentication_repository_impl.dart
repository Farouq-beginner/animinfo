import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';

class FirebaseAuthenticationRepositoryImpl implements AuthenticationRepository {
  final fb.FirebaseAuth _auth;

  FirebaseAuthenticationRepositoryImpl({fb.FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? fb.FirebaseAuth.instance;

  User _mapFbUser(fb.User user) => User(
        id: user.uid.hashCode, // keep int id for existing entity
        username: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        password: '', // never expose real password
      );

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        return Left(ServerFailure('Login failed')); 
      }
      return Right(_mapFbUser(fbUser));
    } on fb.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Auth error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected login error'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String username, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      if (fbUser == null) {
        return Left(ServerFailure('Registration failed'));
      }
      // Update display name
      await fbUser.updateDisplayName(username);
      await fbUser.reload();
      final refreshed = _auth.currentUser;
      return Right(_mapFbUser(refreshed ?? fbUser));
    } on fb.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Auth error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected register error'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) {
      return Left(CacheFailure('No user logged in'));
    }
    return Right(_mapFbUser(fbUser));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } on fb.FirebaseAuthException catch (e) {
      return Left(ServerFailure(e.message ?? 'Logout error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected logout error'));
    }
  }
}