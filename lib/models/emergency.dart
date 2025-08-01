import 'package:cloud_firestore/cloud_firestore.dart';

enum EmergencyStatus {
  active,
  responded,
  resolved,
  cancelled,
}

enum EmergencyType {
  medical,
  accident,
  heartAttack,
  stroke,
  other,
}

class Emergency {
  final String id;
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final double latitude;
  final double longitude;
  final String? address;
  final EmergencyType type;
  final EmergencyStatus status;
  final String? description;
  final String? assignedDoctorId;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? resolvedAt;

  Emergency({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.type,
    required this.status,
    this.description,
    this.assignedDoctorId,
    required this.createdAt,
    this.respondedAt,
    this.resolvedAt,
  });

  factory Emergency.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Emergency(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientPhone: data['patientPhone'],
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      address: data['address'],
      type: EmergencyType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => EmergencyType.medical,
      ),
      status: EmergencyStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => EmergencyStatus.active,
      ),
      description: data['description'],
      assignedDoctorId: data['assignedDoctorId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'type': type.name,
      'status': status.name,
      'description': description,
      'assignedDoctorId': assignedDoctorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  Emergency copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? patientPhone,
    double? latitude,
    double? longitude,
    String? address,
    EmergencyType? type,
    EmergencyStatus? status,
    String? description,
    String? assignedDoctorId,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? resolvedAt,
  }) {
    return Emergency(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}