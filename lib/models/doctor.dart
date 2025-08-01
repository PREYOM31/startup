import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String email;
  final bool isAvailable;
  final String? profileImage;
  final String? phoneNumber;
  final double? rating;
  final int? experienceYears;
  final String? hospitalName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.email,
    required this.isAvailable,
    this.profileImage,
    this.phoneNumber,
    this.rating,
    this.experienceYears,
    this.hospitalName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Doctor(
      id: doc.id,
      name: data['name'] ?? '',
      specialization: data['specialization'] ?? '',
      email: data['email'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      profileImage: data['profileImage'],
      phoneNumber: data['phoneNumber'],
      rating: data['rating']?.toDouble(),
      experienceYears: data['experienceYears'],
      hospitalName: data['hospitalName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialization': specialization,
      'email': email,
      'isAvailable': isAvailable,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'experienceYears': experienceYears,
      'hospitalName': hospitalName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialization,
    String? email,
    bool? isAvailable,
    String? profileImage,
    String? phoneNumber,
    double? rating,
    int? experienceYears,
    String? hospitalName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      email: email ?? this.email,
      isAvailable: isAvailable ?? this.isAvailable,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating ?? this.rating,
      experienceYears: experienceYears ?? this.experienceYears,
      hospitalName: hospitalName ?? this.hospitalName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}