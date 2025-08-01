import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';
import '../models/emergency.dart';
import 'doctor_provider.dart';

// Active emergencies provider
final activeEmergenciesProvider = StreamProvider<List<Emergency>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getActiveEmergencies();
});

// Patient emergencies provider
final patientEmergenciesProvider = StreamProvider.family<List<Emergency>, String>((ref, patientId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPatientEmergencies(patientId);
});

// Emergency creation notifier
class EmergencyNotifier extends StateNotifier<AsyncValue<String?>> {
  final FirestoreService _firestoreService;

  EmergencyNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<String> createEmergency({
    required String patientId,
    required String patientName,
    String? patientPhone,
    required EmergencyType type,
    String? description,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      // Get current location
      final locationResult = await LocationService.getLocationWithErrorHandling();
      
      if (!locationResult['success']) {
        throw Exception('Unable to get location: ${locationResult['error']}');
      }
      
      final Position position = locationResult['position'];
      final String address = locationResult['address'];
      
      // Create emergency object
      final emergency = Emergency(
        id: '', // Will be set by Firestore
        patientId: patientId,
        patientName: patientName,
        patientPhone: patientPhone,
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        type: type,
        status: EmergencyStatus.active,
        description: description,
        createdAt: DateTime.now(),
      );
      
      final emergencyId = await _firestoreService.createEmergency(emergency);
      state = AsyncValue.data(emergencyId);
      return emergencyId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateEmergencyStatus(String emergencyId, EmergencyStatus status) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.updateEmergencyStatus(emergencyId, status);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> assignDoctorToEmergency(String emergencyId, String doctorId) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.assignDoctorToEmergency(emergencyId, doctorId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Emergency notifier provider
final emergencyNotifierProvider = StateNotifierProvider<EmergencyNotifier, AsyncValue<String?>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return EmergencyNotifier(firestoreService);
});

// Location permission status provider
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await LocationService.checkLocationPermission();
});

// Current location provider
final currentLocationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await LocationService.getLocationWithErrorHandling();
});

// Location stream provider for real-time tracking
final locationStreamProvider = StreamProvider<Position>((ref) {
  return LocationService.getPositionStream();
});

// Emergency form state provider
final emergencyFormStateProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'type': EmergencyType.medical,
  'description': '',
});

// Location service enabled provider
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  return await LocationService.isLocationServiceEnabled();
});

// Emergency statistics provider
final emergencyStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final emergenciesAsync = ref.watch(activeEmergenciesProvider);
  
  return emergenciesAsync.when(
    data: (emergencies) {
      final stats = <String, int>{
        'total': emergencies.length,
        'active': emergencies.where((e) => e.status == EmergencyStatus.active).length,
        'responded': emergencies.where((e) => e.status == EmergencyStatus.responded).length,
        'resolved': emergencies.where((e) => e.status == EmergencyStatus.resolved).length,
        'medical': emergencies.where((e) => e.type == EmergencyType.medical).length,
        'accident': emergencies.where((e) => e.type == EmergencyType.accident).length,
        'heartAttack': emergencies.where((e) => e.type == EmergencyType.heartAttack).length,
        'stroke': emergencies.where((e) => e.type == EmergencyType.stroke).length,
        'other': emergencies.where((e) => e.type == EmergencyType.other).length,
      };
      
      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Recent emergencies provider (last 24 hours)
final recentEmergenciesProvider = Provider<AsyncValue<List<Emergency>>>((ref) {
  final emergenciesAsync = ref.watch(activeEmergenciesProvider);
  
  return emergenciesAsync.when(
    data: (emergencies) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));
      
      final recentEmergencies = emergencies.where((emergency) {
        return emergency.createdAt.isAfter(yesterday);
      }).toList();
      
      // Sort by creation time (most recent first)
      recentEmergencies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return AsyncValue.data(recentEmergencies);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Emergency distance calculator provider
final emergencyDistanceProvider = Provider.family<double?, Map<String, dynamic>>((ref, params) {
  final Emergency emergency = params['emergency'];
  final double? userLat = params['userLatitude'];
  final double? userLng = params['userLongitude'];
  
  if (userLat == null || userLng == null) return null;
  
  return LocationService.calculateDistance(
    userLat,
    userLng,
    emergency.latitude,
    emergency.longitude,
  );
});

// Nearest emergencies provider
final nearestEmergenciesProvider = Provider.family<AsyncValue<List<Emergency>>, Map<String, double>>((ref, userLocation) {
  final emergenciesAsync = ref.watch(activeEmergenciesProvider);
  
  return emergenciesAsync.when(
    data: (emergencies) {
      final userLat = userLocation['latitude']!;
      final userLng = userLocation['longitude']!;
      
      // Calculate distances and sort by nearest
      final emergenciesWithDistance = emergencies.map((emergency) {
        final distance = LocationService.calculateDistance(
          userLat,
          userLng,
          emergency.latitude,
          emergency.longitude,
        );
        return {'emergency': emergency, 'distance': distance};
      }).toList();
      
      // Sort by distance
      emergenciesWithDistance.sort((a, b) => 
        (a['distance'] as double).compareTo(b['distance'] as double));
      
      // Return sorted emergencies
      final sortedEmergencies = emergenciesWithDistance
          .map((item) => item['emergency'] as Emergency)
          .toList();
      
      return AsyncValue.data(sortedEmergencies);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});