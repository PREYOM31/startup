import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/booking_provider.dart';

class DoctorDashboard extends ConsumerStatefulWidget {
  const DoctorDashboard({super.key});

  @override
  ConsumerState<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends ConsumerState<DoctorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _EmergenciesTab(),
          _BookingsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'Emergencies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(currentDoctorProvider);
    final emergencyStatsAsync = ref.watch(emergencyStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              doctorAsync.when(
                data: (doctor) {
                  if (doctor == null) return const SizedBox();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, Dr. ${doctor.name}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      if (doctor.hospitalName != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          doctor.hospitalName!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConstants.textHintColor,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading doctor info'),
              ),
              
              SizedBox(height: 32.h),
              
              // Availability Toggle
              doctorAsync.when(
                data: (doctor) {
                  if (doctor == null) return const SizedBox();
                  
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Availability Status',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.isAvailable ? 'Available' : 'Offline',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: doctor.isAvailable 
                                            ? AppConstants.availableColor
                                            : AppConstants.offlineColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      doctor.isAvailable 
                                          ? 'Patients can book appointments with you'
                                          : 'You are not accepting new appointments',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: doctor.isAvailable,
                                onChanged: (value) {
                                  ref.read(doctorAvailabilityProvider(doctor.id).notifier)
                                      .setAvailability(value);
                                },
                                activeColor: AppConstants.availableColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              
              SizedBox(height: 24.h),
              
              // Emergency Statistics
              Text(
                'Emergency Overview',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              
              emergencyStatsAsync.when(
                data: (stats) => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        stats['active']?.toString() ?? '0',
                        AppConstants.emergencyColor,
                        Icons.emergency,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatCard(
                        'Responded',
                        stats['responded']?.toString() ?? '0',
                        AppConstants.warningColor,
                        Icons.support_agent,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatCard(
                        'Resolved',
                        stats['resolved']?.toString() ?? '0',
                        AppConstants.successColor,
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading statistics'),
              ),
              
              SizedBox(height: 24.h),
              
              // Today's Appointments
              doctorAsync.when(
                data: (doctor) {
                  if (doctor == null) return const SizedBox();
                  
                  final todayAppointmentsAsync = ref.watch(todayAppointmentsProvider(doctor.id));
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Appointments',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      
                      todayAppointmentsAsync.when(
                        data: (appointments) {
                          if (appointments.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: AppConstants.backgroundColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 48.sp,
                                    color: AppConstants.textHintColor,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'No appointments today',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return Column(
                            children: appointments.take(3).map((appointment) {
                              return Card(
                                margin: EdgeInsets.only(bottom: 8.h),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    appointment.patientName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Time: ${appointment.appointmentTime}',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(appointment.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      appointment.status.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(appointment.status),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading appointments'),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(status) {
    switch (status.name) {
      case 'confirmed':
        return AppConstants.confirmedColor;
      case 'pending':
        return AppConstants.pendingColor;
      case 'completed':
        return AppConstants.completedColor;
      case 'cancelled':
        return AppConstants.cancelledColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }
}

class _EmergenciesTab extends ConsumerWidget {
  const _EmergenciesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergenciesAsync = ref.watch(activeEmergenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Emergencies'),
        automaticallyImplyLeading: false,
      ),
      body: emergenciesAsync.when(
        data: (emergencies) {
          if (emergencies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emergency_outlined,
                    size: 64.sp,
                    color: AppConstants.textHintColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No active emergencies',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final emergency = emergencies[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emergency,
                            color: AppConstants.emergencyColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              emergency.patientName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.emergencyColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              emergency.type.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.emergencyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      if (emergency.description != null) ...[
                        Text(
                          emergency.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16.sp,
                            color: AppConstants.textHintColor,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              emergency.address ?? 'Location unavailable',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppConstants.textHintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Reported: ${emergency.createdAt.toString().substring(0, 16)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppConstants.textHintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Error loading emergencies'),
        ),
      ),
    );
  }
}

class _BookingsTab extends ConsumerWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Bookings management - Coming Soon'),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text('Doctor Profile - Coming Soon'),
      ),
    );
  }
}