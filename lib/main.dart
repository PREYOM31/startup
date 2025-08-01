import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: MetecogyApp(),
    ),
  );
}

class MetecogyApp extends ConsumerWidget {
  const MetecogyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: AppConstants.primaryColor,
            scaffoldBackgroundColor: AppConstants.backgroundColor,
            fontFamily: 'Poppins',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                ),
                textStyle: AppTextStyles.button,
              ),
            ),
            cardTheme: CardTheme(
              color: AppConstants.cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: const BorderSide(color: AppConstants.textHintColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: const BorderSide(color: AppConstants.textHintColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: const BorderSide(color: AppConstants.errorColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
            ),
          ),
          home: const AuthWrapper(),
          routes: {
            AppConstants.loginRoute: (context) => const LoginScreen(),
            AppConstants.registerRoute: (context) => const RegisterScreen(),
            AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
            AppConstants.patientDashboardRoute: (context) => const PatientDashboard(),
            AppConstants.doctorDashboardRoute: (context) => const DoctorDashboard(),
            AppConstants.bookingRoute: (context) => const BookingScreen(),
            AppConstants.emergencyRoute: (context) => const EmergencyScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(currentUserProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const SplashScreen();
        } else {
          return const UserTypeWrapper();
        }
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) => const SplashScreen(),
    );
  }
}

class UserTypeWrapper extends ConsumerWidget {
  const UserTypeWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    
    if (user == null) {
      return const SplashScreen();
    }
    
    final userTypeAsync = ref.watch(userTypeProvider(user.uid));
    
    return userTypeAsync.when(
      data: (userType) {
        if (userType == null) {
          // User type not found, redirect to login
          return const LoginScreen();
        }
        
        switch (userType) {
          case UserType.patient:
            return const PatientDashboard();
          case UserType.doctor:
            return const DoctorDashboard();
        }
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) => const LoginScreen(),
    );
  }
}