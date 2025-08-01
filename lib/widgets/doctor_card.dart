import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/doctor.dart';
import '../constants/app_constants.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Doctor Avatar
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: doctor.profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30.r),
                        child: Image.network(
                          doctor.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),
              
              SizedBox(width: 16.w),
              
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    Text(
                      doctor.specialization,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    
                    SizedBox(height: 8.h),
                    
                    Row(
                      children: [
                        // Availability Status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: doctor.isAvailable 
                                ? AppConstants.availableColor.withOpacity(0.1)
                                : AppConstants.offlineColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: doctor.isAvailable 
                                      ? AppConstants.availableColor
                                      : AppConstants.offlineColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                doctor.isAvailable ? 'Available' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: doctor.isAvailable 
                                      ? AppConstants.availableColor
                                      : AppConstants.offlineColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Rating (if available)
                        if (doctor.rating != null) ...[
                          Icon(
                            Icons.star,
                            size: 16.sp,
                            color: AppConstants.warningColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            doctor.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Hospital Name (if available)
                    if (doctor.hospitalName != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            size: 12.sp,
                            color: AppConstants.textHintColor,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              doctor.hospitalName!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppConstants.textHintColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Experience (if available)
                    if (doctor.experienceYears != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        '${doctor.experienceYears} years experience',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppConstants.textHintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: AppConstants.textHintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 30.sp,
      color: AppConstants.primaryColor,
    );
  }
}