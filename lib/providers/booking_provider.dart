import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/booking.dart';
import 'doctor_provider.dart';

// Patient bookings provider
final patientBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, patientId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPatientBookings(patientId);
});

// Doctor bookings provider
final doctorBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, doctorId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDoctorBookings(doctorId);
});

// Booking by ID provider
final bookingByIdProvider = FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getBookingById(bookingId);
});

// Available time slots provider
final availableTimeSlotsProvider = FutureProvider.family<List<String>, Map<String, dynamic>>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final doctorId = params['doctorId'] as String;
  final date = params['date'] as DateTime;
  return await firestoreService.getAvailableTimeSlots(doctorId, date);
});

// Booking creation notifier
class BookingNotifier extends StateNotifier<AsyncValue<String?>> {
  final FirestoreService _firestoreService;

  BookingNotifier(this._firestoreService) : super(const AsyncValue.data(null));

  Future<String> createBooking(Booking booking) async {
    try {
      state = const AsyncValue.loading();
      final bookingId = await _firestoreService.createBooking(booking);
      state = AsyncValue.data(bookingId);
      return bookingId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      state = const AsyncValue.loading();
      await _firestoreService.updateBookingStatus(bookingId, status);
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

// Booking notifier provider
final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, AsyncValue<String?>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return BookingNotifier(firestoreService);
});

// Selected booking date provider
final selectedBookingDateProvider = StateProvider<DateTime?>((ref) => null);

// Selected booking time provider
final selectedBookingTimeProvider = StateProvider<String?>((ref) => null);

// Selected doctor for booking provider
final selectedDoctorForBookingProvider = StateProvider<String?>((ref) => null);

// Booking form state provider
final bookingFormStateProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'symptoms': '',
  'notes': '',
});

// Upcoming bookings provider (for patients)
final upcomingBookingsProvider = Provider.family<AsyncValue<List<Booking>>, String>((ref, patientId) {
  final bookingsAsync = ref.watch(patientBookingsProvider(patientId));
  
  return bookingsAsync.when(
    data: (bookings) {
      final now = DateTime.now();
      final upcomingBookings = bookings.where((booking) {
        return booking.appointmentDate.isAfter(now) && 
               (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending);
      }).toList();
      
      // Sort by appointment date
      upcomingBookings.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      
      return AsyncValue.data(upcomingBookings);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Past bookings provider (for patients)
final pastBookingsProvider = Provider.family<AsyncValue<List<Booking>>, String>((ref, patientId) {
  final bookingsAsync = ref.watch(patientBookingsProvider(patientId));
  
  return bookingsAsync.when(
    data: (bookings) {
      final now = DateTime.now();
      final pastBookings = bookings.where((booking) {
        return booking.appointmentDate.isBefore(now) || 
               booking.status == BookingStatus.completed ||
               booking.status == BookingStatus.cancelled;
      }).toList();
      
      // Sort by appointment date (most recent first)
      pastBookings.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      
      return AsyncValue.data(pastBookings);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Today's appointments provider (for doctors)
final todayAppointmentsProvider = Provider.family<AsyncValue<List<Booking>>, String>((ref, doctorId) {
  final bookingsAsync = ref.watch(doctorBookingsProvider(doctorId));
  
  return bookingsAsync.when(
    data: (bookings) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final todayBookings = bookings.where((booking) {
        return booking.appointmentDate.isAfter(todayStart) && 
               booking.appointmentDate.isBefore(todayEnd) &&
               (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending);
      }).toList();
      
      // Sort by appointment time
      todayBookings.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
      
      return AsyncValue.data(todayBookings);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Booking statistics provider (for doctors)
final bookingStatsProvider = Provider.family<AsyncValue<Map<String, int>>, String>((ref, doctorId) {
  final bookingsAsync = ref.watch(doctorBookingsProvider(doctorId));
  
  return bookingsAsync.when(
    data: (bookings) {
      final stats = <String, int>{
        'total': bookings.length,
        'confirmed': bookings.where((b) => b.status == BookingStatus.confirmed).length,
        'pending': bookings.where((b) => b.status == BookingStatus.pending).length,
        'completed': bookings.where((b) => b.status == BookingStatus.completed).length,
        'cancelled': bookings.where((b) => b.status == BookingStatus.cancelled).length,
      };
      
      return AsyncValue.data(stats);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});