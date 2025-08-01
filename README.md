# Metecogy - Medical Emergency & Doctor Booking App

A comprehensive Flutter application for medical emergencies and doctor appointment booking, featuring real-time location tracking, Firebase integration, and separate interfaces for patients and doctors.

## 🚀 Features

### 👨‍⚕️ Doctor Discovery & Availability
- Browse doctors by specialization (Cardiology, Orthopedics, Neurology, etc.)
- Real-time availability status ("Available now" or "Offline")
- Doctor profiles with ratings, experience, and hospital information
- Search and filter functionality

### 🚨 Emergency Mode (GPS-Based)
- Red emergency button with pulsing animation
- Real-time GPS location tracking
- Emergency type selection (Medical, Accident, Heart Attack, Stroke, Other)
- Automatic location sharing with hospitals and doctors
- Emergency confirmation screen with tracking ID

### 📅 Doctor Booking System
- Select doctors and view available time slots
- Date and time picker with real-time availability
- Booking confirmation with patient details
- Symptoms and notes recording
- Booking status tracking (Pending, Confirmed, Completed, Cancelled)

### 🔐 Authentication System
- **Patient Login**: Email or Phone number authentication
- **Doctor Login**: Email and password authentication
- Firebase Authentication integration
- User type detection and routing
- Secure session management

### 📍 Live Location Tracking
- Real-time GPS location fetching using Geolocator
- Address resolution from coordinates
- Location permission handling
- Distance calculations between users and emergencies

### 🎨 Modern UI/UX
- Beautiful Material Design interface
- Responsive design with ScreenUtil
- Smooth animations and transitions
- Dark/Light theme support ready
- Professional medical app aesthetics

## 🛠 Tech Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | Flutter (Dart) |
| **State Management** | Riverpod |
| **Authentication** | Firebase Authentication |
| **Database** | Firebase Firestore |
| **Location Services** | Geolocator, Geocoding |
| **Maps** | Google Maps API (Ready for integration) |
| **Push Notifications** | Firebase Cloud Messaging (Ready) |
| **UI Framework** | Material Design |
| **Responsive Design** | Flutter ScreenUtil |

## 📱 App Structure

```
lib/
├── constants/          # App constants, colors, styles
├── models/            # Data models (Doctor, Patient, Booking, Emergency)
├── providers/         # Riverpod state management
├── screens/           # UI screens and pages
│   ├── auth/         # Login and registration
│   ├── patient/      # Patient dashboard
│   ├── doctor/       # Doctor dashboard
│   ├── booking/      # Appointment booking
│   ├── emergency/    # Emergency features
│   └── onboarding/   # App introduction
├── services/         # Business logic and API calls
├── widgets/          # Reusable UI components
└── utils/            # Helper functions
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.4.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project
- Google Maps API key (optional for maps)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd metecogy
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "Metecogy"
3. Enable Authentication and Firestore Database

#### Configure Firebase for Flutter
1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

4. Configure Firebase for your project:
```bash
flutterfire configure
```

5. Update `lib/firebase_options.dart` with your actual Firebase configuration

#### Enable Authentication Methods
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Email/Password and Phone authentication

#### Setup Firestore Database
1. In Firebase Console, go to Firestore Database
2. Create database in test mode
3. The app will automatically create required collections

### 4. Configure Permissions

#### Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### iOS Permissions (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to provide emergency services and find nearby doctors.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to provide emergency services and find nearby doctors.</string>
```

### 5. Google Maps Setup (Optional)
1. Get Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Maps SDK for Android and iOS
3. Add API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_API_KEY_HERE"/>
```

### 6. Run the Application
```bash
flutter run
```

## 🎯 Usage Guide

### For Patients
1. **Registration**: Create account with email and personal details
2. **Doctor Discovery**: Browse doctors by specialization or search
3. **Book Appointments**: Select doctor, date, and time slot
4. **Emergency**: Use red emergency button for immediate help
5. **Track Bookings**: View appointment history and status

### For Doctors
1. **Registration**: Create account with medical specialization
2. **Availability Toggle**: Control when patients can book appointments
3. **View Emergencies**: Monitor active emergency requests
4. **Manage Bookings**: View and manage patient appointments
5. **Profile Management**: Update professional information

## 🔥 Firebase Collections Structure

### Doctors Collection
```javascript
{
  "name": "Dr. John Smith",
  "email": "doctor@example.com",
  "specialization": "Cardiology",
  "isAvailable": true,
  "phoneNumber": "+1234567890",
  "hospitalName": "City Hospital",
  "rating": 4.5,
  "experienceYears": 10,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Patients Collection
```javascript
{
  "name": "Jane Doe",
  "email": "patient@example.com",
  "phoneNumber": "+1234567890",
  "dateOfBirth": "timestamp",
  "bloodGroup": "O+",
  "emergencyContact": "+1234567890",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Bookings Collection
```javascript
{
  "doctorId": "doctor_id",
  "patientId": "patient_id",
  "patientName": "Jane Doe",
  "appointmentDate": "timestamp",
  "appointmentTime": "14:30",
  "status": "confirmed",
  "symptoms": "Chest pain",
  "notes": "Follow-up appointment",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Emergencies Collection
```javascript
{
  "patientId": "patient_id",
  "patientName": "Jane Doe",
  "patientPhone": "+1234567890",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "address": "123 Main St, New York, NY",
  "type": "heartAttack",
  "status": "active",
  "description": "Severe chest pain",
  "assignedDoctorId": "doctor_id",
  "createdAt": "timestamp",
  "respondedAt": "timestamp",
  "resolvedAt": "timestamp"
}
```

## 🧪 Testing

### Test Users
Create test accounts for both user types:

**Test Patient:**
- Email: patient@test.com
- Password: test123

**Test Doctor:**
- Email: doctor@test.com
- Password: test123
- Specialization: General Practice

### Test Emergency Flow
1. Login as patient
2. Tap emergency button
3. Grant location permissions
4. Select emergency type
5. Submit emergency request
6. Check doctor dashboard for emergency notification

### Test Booking Flow
1. Login as patient
2. Browse available doctors
3. Select a doctor
4. Choose date and time
5. Add symptoms/notes
6. Confirm booking
7. Check doctor dashboard for new booking

## 📋 Success Criteria Checklist

- ✅ Emergency button triggers GPS location sharing
- ✅ Doctor availability toggle works in real-time
- ✅ Booking system stores data in Firestore
- ✅ All flows work on real devices
- ✅ Firebase Authentication integrated
- ✅ Location services properly implemented
- ✅ Modern, professional UI design
- ✅ Responsive design for multiple screen sizes

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🔮 Future Enhancements

- [ ] Push notifications for emergencies and bookings
- [ ] Google Maps integration for location visualization
- [ ] Video consultation feature
- [ ] Medical document upload
- [ ] AI-powered symptom analysis
- [ ] Multi-language support
- [ ] Prescription management
- [ ] Insurance integration

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Email: support@metecogy.com
- Documentation: [Wiki](../../wiki)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI guidelines
- Open source community for packages used

---

**Built with ❤️ using Flutter**