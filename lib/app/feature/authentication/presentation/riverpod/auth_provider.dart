import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/authentication_repository_impl.dart';
import '../../domain/repository/authentication_repository.dart';
import '../../domain/entity/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:esignature/app/core/data/local/local_data.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Stream of Auth State (UserEntity or null)
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    if (user != null) {
      return UserEntity(id: user.uid, email: user.email ?? '');
    }
    return null;
  });
});

// Auth Controller for Actions (Login, Signup, Logout)
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  // GetIt instance for LocalData (Assuming it's registered)
  final LocalData _localData = GetIt.I<LocalData>();

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.login(email, password);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) {
        // Update LocalData
        _localData.setLoginStatus(true);
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> signup(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signup(email, password);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (user) {
        // Update LocalData
        _localData.setLoginStatus(true);
        state = const AsyncValue.data(null);
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    _localData.setLoginStatus(false);
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.watch(authRepositoryProvider));
    });
