import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../models/emergency.dart';
import '../../widgets/emergency_button.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  EmergencyType _selectedType = EmergencyType.medical;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isRequestingHelp = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _requestEmergencyHelp() async {
    final patient = await ref.read(currentPatientProvider.future);
    if (patient == null) {
      _showErrorMessage('User information not found');
      return;
    }

    setState(() {
      _isRequestingHelp = true;
    });

    try {
      final emergencyId = await ref.read(emergencyNotifierProvider.notifier).createEmergency(
        patientId: patient.id,
        patientName: patient.name,
        patientPhone: patient.phoneNumber,
        type: _selectedType,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EmergencyConfirmationScreen(emergencyId: emergencyId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingHelp = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationPermissionAsync = ref.watch(locationPermissionProvider);
    final locationServiceEnabledAsync = ref.watch(locationServiceEnabledProvider);

    return Scaffold(
      backgroundColor: AppConstants.emergencyColor,
      appBar: AppBar(
        backgroundColor: AppConstants.emergencyColor,
        foregroundColor: Colors.white,
        title: const Text('Emergency Help'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Message
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 48.sp,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Emergency Services',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'This will send your location to nearby hospitals and doctors for immediate assistance.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Location Status
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Services',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    // Location Service Status
                    locationServiceEnabledAsync.when(
                      data: (isEnabled) => _buildStatusRow(
                        'Location Services',
                        isEnabled,
                        isEnabled ? 'Enabled' : 'Disabled',
                      ),
                      loading: () => _buildStatusRow('Location Services', null, 'Checking...'),
                      error: (_, __) => _buildStatusRow('Location Services', false, 'Error'),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    // Permission Status
                    locationPermissionAsync.when(
                      data: (permission) {
                        final isGranted = permission.name == 'whileInUse' || permission.name == 'always';
                        return _buildStatusRow(
                          'Location Permission',
                          isGranted,
                          isGranted ? 'Granted' : 'Not Granted',
                        );
                      },
                      loading: () => _buildStatusRow('Location Permission', null, 'Checking...'),
                      error: (_, __) => _buildStatusRow('Location Permission', false, 'Error'),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Emergency Type Selection
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Type',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    ...EmergencyType.values.map((type) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: RadioListTile<EmergencyType>(
                          value: type,
                          groupValue: _selectedType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                          title: Text(
                            _getEmergencyTypeLabel(type),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          activeColor: AppConstants.emergencyColor,
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Description Field
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information (Optional)',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Describe the emergency situation...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // Emergency Button
              _isRequestingHelp
                  ? Container(
                      width: double.infinity,
                      height: 120.h,
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      decoration: BoxDecoration(
                        color: AppConstants.emergencyColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : LargeEmergencyButton(
                      text: 'REQUEST HELP NOW',
                      onPressed: _requestEmergencyHelp,
                    ),
              
              SizedBox(height: 24.h),
              
              // Disclaimer
              Text(
                'By requesting emergency help, you consent to sharing your location with medical professionals and emergency services.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool? status, String statusText) {
    return Row(
      children: [
        Icon(
          status == true ? Icons.check_circle : status == false ? Icons.cancel : Icons.help,
          size: 20.sp,
          color: status == true 
              ? AppConstants.successColor 
              : status == false 
                  ? AppConstants.errorColor 
                  : AppConstants.warningColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12.sp,
            color: status == true 
                ? AppConstants.successColor 
                : status == false 
                    ? AppConstants.errorColor 
                    : AppConstants.warningColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getEmergencyTypeLabel(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'Medical Emergency';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.heartAttack:
        return 'Heart Attack';
      case EmergencyType.stroke:
        return 'Stroke';
      case EmergencyType.other:
        return 'Other';
    }
  }
}

class EmergencyConfirmationScreen extends StatelessWidget {
  final String emergencyId;

  const EmergencyConfirmationScreen({
    super.key,
    required this.emergencyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.successColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100.sp,
                color: Colors.white,
              ),
              
              SizedBox(height: 32.h),
              
              Text(
                'Help is on the way!',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              Text(
                'Your emergency request has been sent successfully. Nearby hospitals and doctors have been notified of your location.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 24.h),
              
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      'Emergency ID',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      emergencyId,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppConstants.successColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}