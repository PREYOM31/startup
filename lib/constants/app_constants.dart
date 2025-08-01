import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Metecogy';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Medical Emergency & Doctor Booking App';

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryDarkColor = Color(0xFF1976D2);
  static const Color primaryLightColor = Color(0xFFBBDEFB);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE57373);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  
  // Emergency Colors
  static const Color emergencyColor = Color(0xFFD32F2F);
  static const Color emergencyLightColor = Color(0xFFFFCDD2);
  static const Color emergencyDarkColor = Color(0xFFB71C1C);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color availableColor = Color(0xFF4CAF50);
  static const Color offlineColor = Color(0xFF9E9E9E);
  static const Color pendingColor = Color(0xFFFF9800);
  static const Color confirmedColor = Color(0xFF2196F3);
  static const Color completedColor = Color(0xFF4CAF50);
  static const Color cancelledColor = Color(0xFFE57373);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeadline = 28.0;
  
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // Specializations
  static const List<String> medicalSpecializations = [
    'Cardiology',
    'Dermatology',
    'Emergency Medicine',
    'Endocrinology',
    'Gastroenterology',
    'General Practice',
    'Gynecology',
    'Hematology',
    'Internal Medicine',
    'Neurology',
    'Oncology',
    'Ophthalmology',
    'Orthopedics',
    'Otolaryngology',
    'Pediatrics',
    'Psychiatry',
    'Pulmonology',
    'Radiology',
    'Surgery',
    'Urology',
  ];
  
  // Emergency Types
  static const List<String> emergencyTypes = [
    'Medical Emergency',
    'Accident',
    'Heart Attack',
    'Stroke',
    'Other',
  ];
  
  // Time Slots
  static const List<String> availableTimeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00'
  ];
  
  // API Endpoints (if needed)
  static const String baseUrl = 'https://api.metecogy.com';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
  static const String authenticationError = 'Authentication failed. Please login again.';
  static const String permissionDeniedError = 'Permission denied. Please grant required permissions.';
  static const String locationError = 'Unable to get location. Please enable location services.';
  
  // Success Messages
  static const String bookingSuccessMessage = 'Booking confirmed successfully!';
  static const String emergencySuccessMessage = 'Emergency request sent successfully!';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully!';
  
  // Validation Messages
  static const String requiredFieldError = 'This field is required';
  static const String invalidEmailError = 'Please enter a valid email address';
  static const String weakPasswordError = 'Password must be at least 6 characters long';
  static const String passwordMismatchError = 'Passwords do not match';
  static const String invalidPhoneError = 'Please enter a valid phone number';
  
  // SharedPreferences Keys
  static const String userTypeKey = 'user_type';
  static const String isFirstTimeKey = 'is_first_time';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String doctorDashboardRoute = '/doctor-dashboard';
  static const String patientDashboardRoute = '/patient-dashboard';
  static const String bookingRoute = '/booking';
  static const String emergencyRoute = '/emergency';
  static const String profileRoute = '/profile';
  
  // Image Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String splashImagePath = 'assets/images/splash.png';
  static const String onboardingImage1Path = 'assets/images/onboarding1.png';
  static const String onboardingImage2Path = 'assets/images/onboarding2.png';
  static const String onboardingImage3Path = 'assets/images/onboarding3.png';
  static const String doctorPlaceholderPath = 'assets/images/doctor_placeholder.png';
  static const String patientPlaceholderPath = 'assets/images/patient_placeholder.png';
  
  // Icon Assets
  static const String emergencyIconPath = 'assets/icons/emergency.png';
  static const String heartIconPath = 'assets/icons/heart.png';
  static const String stethoscopeIconPath = 'assets/icons/stethoscope.png';
  
  // Firebase Collections
  static const String doctorsCollection = 'doctors';
  static const String patientsCollection = 'patients';
  static const String bookingsCollection = 'bookings';
  static const String emergenciesCollection = 'emergencies';
  
  // Notification Settings
  static const String emergencyNotificationChannel = 'emergency_notifications';
  static const String bookingNotificationChannel = 'booking_notifications';
  static const String generalNotificationChannel = 'general_notifications';
}

// Text Styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: AppConstants.fontSizeHeadline,
    fontWeight: FontWeight.bold,
    color: AppConstants.textPrimaryColor,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: AppConstants.fontSizeTitle,
    fontWeight: FontWeight.bold,
    color: AppConstants.textPrimaryColor,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.normal,
    color: AppConstants.textPrimaryColor,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontSize: AppConstants.fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: AppConstants.textSecondaryColor,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: AppConstants.fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: AppConstants.textHintColor,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: AppConstants.fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}