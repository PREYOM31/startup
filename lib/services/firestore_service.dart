import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import '../models/booking.dart';
import '../models/emergency.dart';
import '../models/patient.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // DOCTOR OPERATIONS
  
  // Get all doctors
  Stream<List<Doctor>> getDoctors() {
    return _firestore
        .collection('doctors')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Doctor.fromFirestore(doc))
            .toList());
  }

  // Get doctors by specialization
  Stream<List<Doctor>> getDoctorsBySpecialization(String specialization) {
    return _firestore
        .collection('doctors')
        .where('specialization', isEqualTo: specialization)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Doctor.fromFirestore(doc))
            .toList());
  }

  // Get available doctors
  Stream<List<Doctor>> getAvailableDoctors() {
    return _firestore
        .collection('doctors')
        .where('isAvailable', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Doctor.fromFirestore(doc))
            .toList());
  }

  // Get doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();
      
      if (doc.exists) {
        return Doctor.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting doctor: $e');
    }
  }

  // Update doctor availability
  Future<void> updateDoctorAvailability(String doctorId, bool isAvailable) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .update({
            'isAvailable': isAvailable,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Error updating doctor availability: $e');
    }
  }

  // Update doctor profile
  Future<void> updateDoctorProfile(String doctorId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore
          .collection('doctors')
          .doc(doctorId)
          .update(data);
    } catch (e) {
      throw Exception('Error updating doctor profile: $e');
    }
  }

  // BOOKING OPERATIONS

  // Create a new booking
  Future<String> createBooking(Booking booking) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('bookings')
          .add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Get bookings for a patient
  Stream<List<Booking>> getPatientBookings(String patientId) {
    return _firestore
        .collection('bookings')
        .where('patientId', isEqualTo: patientId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList());
  }

  // Get bookings for a doctor
  Stream<List<Booking>> getDoctorBookings(String doctorId) {
    return _firestore
        .collection('bookings')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList());
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({
            'status': status.name,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();
      
      if (doc.exists) {
        return Booking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting booking: $e');
    }
  }

  // EMERGENCY OPERATIONS

  // Create emergency request
  Future<String> createEmergency(Emergency emergency) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('emergencies')
          .add(emergency.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating emergency: $e');
    }
  }

  // Get active emergencies
  Stream<List<Emergency>> getActiveEmergencies() {
    return _firestore
        .collection('emergencies')
        .where('status', isEqualTo: EmergencyStatus.active.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Emergency.fromFirestore(doc))
            .toList());
  }

  // Get patient emergencies
  Stream<List<Emergency>> getPatientEmergencies(String patientId) {
    return _firestore
        .collection('emergencies')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Emergency.fromFirestore(doc))
            .toList());
  }

  // Update emergency status
  Future<void> updateEmergencyStatus(String emergencyId, EmergencyStatus status) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.name,
      };

      if (status == EmergencyStatus.responded) {
        updateData['respondedAt'] = Timestamp.now();
      } else if (status == EmergencyStatus.resolved) {
        updateData['resolvedAt'] = Timestamp.now();
      }

      await _firestore
          .collection('emergencies')
          .doc(emergencyId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error updating emergency status: $e');
    }
  }

  // Assign doctor to emergency
  Future<void> assignDoctorToEmergency(String emergencyId, String doctorId) async {
    try {
      await _firestore
          .collection('emergencies')
          .doc(emergencyId)
          .update({
            'assignedDoctorId': doctorId,
            'status': EmergencyStatus.responded.name,
            'respondedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Error assigning doctor to emergency: $e');
    }
  }

  // PATIENT OPERATIONS

  // Update patient profile
  Future<void> updatePatientProfile(String patientId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore
          .collection('patients')
          .doc(patientId)
          .update(data);
    } catch (e) {
      throw Exception('Error updating patient profile: $e');
    }
  }

  // Get patient by ID
  Future<Patient?> getPatientById(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();
      
      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting patient: $e');
    }
  }

  // UTILITY OPERATIONS

  // Get available time slots for a doctor on a specific date
  Future<List<String>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      // Get existing bookings for the doctor on the specified date
      QuerySnapshot bookings = await _firestore
          .collection('bookings')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isEqualTo: Timestamp.fromDate(date))
          .where('status', whereIn: [BookingStatus.confirmed.name, BookingStatus.pending.name])
          .get();

      // Extract booked times
      List<String> bookedTimes = bookings.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['appointmentTime'] as String)
          .toList();

      // Generate all possible time slots (9 AM to 5 PM, 30-minute intervals)
      List<String> allTimeSlots = [];
      for (int hour = 9; hour < 17; hour++) {
        allTimeSlots.add('${hour.toString().padLeft(2, '0')}:00');
        allTimeSlots.add('${hour.toString().padLeft(2, '0')}:30');
      }

      // Return available slots (not booked)
      return allTimeSlots.where((slot) => !bookedTimes.contains(slot)).toList();
    } catch (e) {
      throw Exception('Error getting available time slots: $e');
    }
  }

  // Get specializations
  Future<List<String>> getSpecializations() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('doctors').get();
      Set<String> specializations = {};
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['specialization'] != null) {
          specializations.add(data['specialization']);
        }
      }
      
      List<String> sortedSpecializations = specializations.toList()..sort();
      return sortedSpecializations;
    } catch (e) {
      throw Exception('Error getting specializations: $e');
    }
  }
}