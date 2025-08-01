import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? profileImage;
  final String? bloodGroup;
  final List<String>? allergies;
  final String? emergencyContact;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.profileImage,
    this.bloodGroup,
    this.allergies,
    this.emergencyContact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'],
      profileImage: data['profileImage'],
      bloodGroup: data['bloodGroup'],
      allergies: data['allergies'] != null 
          ? List<String>.from(data['allergies'])
          : null,
      emergencyContact: data['emergencyContact'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'profileImage': profileImage,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'emergencyContact': emergencyContact,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? profileImage,
    String? bloodGroup,
    List<String>? allergies,
    String? emergencyContact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}