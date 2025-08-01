import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/doctor.dart';

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// All doctors provider
final doctorsProvider = StreamProvider<List<Doctor>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDoctors();
});

// Available doctors provider
final availableDoctorsProvider = StreamProvider<List<Doctor>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAvailableDoctors();
});

// Doctors by specialization provider
final doctorsBySpecializationProvider = StreamProvider.family<List<Doctor>, String>((ref, specialization) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDoctorsBySpecialization(specialization);
});

// Doctor by ID provider
final doctorByIdProvider = FutureProvider.family<Doctor?, String>((ref, doctorId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getDoctorById(doctorId);
});

// Specializations provider
final specializationsProvider = FutureProvider<List<String>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getSpecializations();
});

// Doctor availability notifier
class DoctorAvailabilityNotifier extends StateNotifier<AsyncValue<bool>> {
  final FirestoreService _firestoreService;
  final String _doctorId;

  DoctorAvailabilityNotifier(this._firestoreService, this._doctorId) 
      : super(const AsyncValue.loading());

  Future<void> toggleAvailability(bool isAvailable) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.updateDoctorAvailability(_doctorId, isAvailable);
      state = AsyncValue.data(isAvailable);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> setAvailability(bool isAvailable) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.updateDoctorAvailability(_doctorId, isAvailable);
      state = AsyncValue.data(isAvailable);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// Doctor availability notifier provider
final doctorAvailabilityProvider = StateNotifierProvider.family<DoctorAvailabilityNotifier, AsyncValue<bool>, String>((ref, doctorId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return DoctorAvailabilityNotifier(firestoreService, doctorId);
});

// Selected specialization filter provider
final selectedSpecializationProvider = StateProvider<String?>((ref) => null);

// Filtered doctors provider (based on selected specialization)
final filteredDoctorsProvider = Provider<AsyncValue<List<Doctor>>>((ref) {
  final selectedSpecialization = ref.watch(selectedSpecializationProvider);
  
  if (selectedSpecialization == null || selectedSpecialization.isEmpty) {
    return ref.watch(doctorsProvider);
  } else {
    return ref.watch(doctorsBySpecializationProvider(selectedSpecialization));
  }
});

// Search query provider
final doctorSearchQueryProvider = StateProvider<String>((ref) => '');

// Searched doctors provider
final searchedDoctorsProvider = Provider<AsyncValue<List<Doctor>>>((ref) {
  final searchQuery = ref.watch(doctorSearchQueryProvider).toLowerCase();
  final doctorsAsync = ref.watch(filteredDoctorsProvider);
  
  return doctorsAsync.when(
    data: (doctors) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(doctors);
      }
      
      final filteredDoctors = doctors.where((doctor) {
        return doctor.name.toLowerCase().contains(searchQuery) ||
               doctor.specialization.toLowerCase().contains(searchQuery) ||
               (doctor.hospitalName?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
      
      return AsyncValue.data(filteredDoctors);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Doctor profile update notifier
class DoctorProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;

  DoctorProfileNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<void> updateProfile(String doctorId, Map<String, dynamic> data) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.updateDoctorProfile(doctorId, data);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// Doctor profile update provider
final doctorProfileNotifierProvider = StateNotifierProvider<DoctorProfileNotifier, AsyncValue<void>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return DoctorProfileNotifier(firestoreService);
});