import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  completed,
}

class Booking {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final BookingStatus status;
  final String? notes;
  final String? symptoms;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    this.symptoms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Booking(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      appointmentTime: data['appointmentTime'] ?? '',
      status: BookingStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: data['notes'],
      symptoms: data['symptoms'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'appointmentTime': appointmentTime,
      'status': status.name,
      'notes': notes,
      'symptoms': symptoms,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Booking copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? patientName,
    DateTime? appointmentDate,
    String? appointmentTime,
    BookingStatus? status,
    String? notes,
    String? symptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}