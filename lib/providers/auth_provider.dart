import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/patient.dart';
import '../models/doctor.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// User type provider
final userTypeProvider = FutureProvider.family<UserType?, String>((ref, uid) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserType(uid);
});

// Current patient provider
final currentPatientProvider = FutureProvider<Patient?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  
  final authService = ref.watch(authServiceProvider);
  return await authService.getPatientData(user.uid);
});

// Current doctor provider
final currentDoctorProvider = FutureProvider<Doctor?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  
  final authService = ref.watch(authServiceProvider);
  return await authService.getDoctorData(user.uid);
});

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  // Sign up patient
  Future<void> signUpPatient({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signUpPatient(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign up doctor
  Future<void> signUpDoctor({
    required String email,
    required String password,
    required String name,
    required String specialization,
    String? phoneNumber,
    String? hospitalName,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signUpDoctor(
        email: email,
        password: password,
        name: name,
        specialization: specialization,
        phoneNumber: phoneNumber,
        hospitalName: hospitalName,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(currentUserProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(currentUserProvider);
  return authState.when(
    data: (user) => user?.uid,
    loading: () => null,
    error: (_, __) => null,
  );
});