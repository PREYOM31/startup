import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';
import '../models/doctor.dart';

enum UserType { patient, doctor }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up patient with email and password
  Future<UserCredential?> signUpPatient({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create patient document in Firestore
      if (credential.user != null) {
        await _createPatientDocument(
          uid: credential.user!.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up doctor with email and password
  Future<UserCredential?> signUpDoctor({
    required String email,
    required String password,
    required String name,
    required String specialization,
    String? phoneNumber,
    String? hospitalName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create doctor document in Firestore
      if (credential.user != null) {
        await _createDoctorDocument(
          uid: credential.user!.uid,
          name: name,
          email: email,
          specialization: specialization,
          phoneNumber: phoneNumber,
          hospitalName: hospitalName,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with phone number (for patients)
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Verify SMS code
  Future<UserCredential?> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user type (patient or doctor)
  Future<UserType?> getUserType(String uid) async {
    try {
      // Check if user exists in patients collection
      DocumentSnapshot patientDoc = await _firestore
          .collection('patients')
          .doc(uid)
          .get();
      
      if (patientDoc.exists) {
        return UserType.patient;
      }

      // Check if user exists in doctors collection
      DocumentSnapshot doctorDoc = await _firestore
          .collection('doctors')
          .doc(uid)
          .get();
      
      if (doctorDoc.exists) {
        return UserType.doctor;
      }

      return null;
    } catch (e) {
      throw Exception('Error getting user type: $e');
    }
  }

  // Get patient data
  Future<Patient?> getPatientData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return Patient.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting patient data: $e');
    }
  }

  // Get doctor data
  Future<Doctor?> getDoctorData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('doctors')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return Doctor.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting doctor data: $e');
    }
  }

  // Create patient document in Firestore
  Future<void> _createPatientDocument({
    required String uid,
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    final patient = Patient(
      id: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('patients')
        .doc(uid)
        .set(patient.toFirestore());
  }

  // Create doctor document in Firestore
  Future<void> _createDoctorDocument({
    required String uid,
    required String name,
    required String email,
    required String specialization,
    String? phoneNumber,
    String? hospitalName,
  }) async {
    final doctor = Doctor(
      id: uid,
      name: name,
      email: email,
      specialization: specialization,
      isAvailable: false, // Default to offline
      phoneNumber: phoneNumber,
      hospitalName: hospitalName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('doctors')
        .doc(uid)
        .set(doctor.toFirestore());
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}