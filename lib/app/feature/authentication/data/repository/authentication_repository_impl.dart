import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repository/authentication_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return Right(UserEntity(id: user.uid, email: user.email ?? ''));
      } else {
        return const Left(AuthenticationFailure(message: 'User not found'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message ?? 'Login failed'));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return Right(UserEntity(id: user.uid, email: user.email ?? ''));
      } else {
        return const Left(
          AuthenticationFailure(message: 'Registration failed'),
        );
      }
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message ?? 'Signup failed'));
    } catch (e) {
      return const Left(ServerFailure(message: 'An unknown error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Logout failed'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return Right(UserEntity(id: user.uid, email: user.email ?? ''));
      }
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get current user'));
    }
  }
}
