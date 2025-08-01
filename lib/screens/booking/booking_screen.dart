import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_constants.dart';
import '../../models/doctor.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Doctor doctor;

  const BookingScreen({
    super.key,
    required this.doctor,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isBooking = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
      _showErrorMessage('Please select date and time');
      return;
    }

    final patient = await ref.read(currentPatientProvider.future);
    if (patient == null) {
      _showErrorMessage('User information not found');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final booking = Booking(
        id: const Uuid().v4(),
        doctorId: widget.doctor.id,
        patientId: patient.id,
        patientName: patient.name,
        appointmentDate: _selectedDate!,
        appointmentTime: _selectedTime!,
        status: BookingStatus.pending,
        symptoms: _symptomsController.text.trim().isNotEmpty 
            ? _symptomsController.text.trim() 
            : null,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(bookingNotifierProvider.notifier).createBooking(booking);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              booking: booking,
              doctor: widget.doctor,
            ),
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
          _isBooking = false;
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
    final availableTimeSlotsAsync = _selectedDate != null
        ? ref.watch(availableTimeSlotsProvider({
            'doctorId': widget.doctor.id,
            'date': _selectedDate!,
          }))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 30.sp,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.doctor.specialization,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                          if (widget.doctor.hospitalName != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              widget.doctor.hospitalName!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppConstants.textHintColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Date Selection
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            
            InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: AppConstants.textHintColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppConstants.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                          : 'Select appointment date',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: _selectedDate != null
                            ? AppConstants.textPrimaryColor
                            : AppConstants.textHintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Time Selection
            if (_selectedDate != null) ...[
              Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              
              availableTimeSlotsAsync?.when(
                data: (timeSlots) {
                  if (timeSlots.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppConstants.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'No available time slots for this date',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppConstants.errorColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  
                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppConstants.primaryColor 
                                : Colors.white,
                            border: Border.all(
                              color: isSelected 
                                  ? AppConstants.primaryColor 
                                  : AppConstants.textHintColor,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppConstants.textPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Text(
                  'Error loading time slots',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppConstants.errorColor,
                  ),
                ),
              ) ?? const SizedBox(),
              
              SizedBox(height: 24.h),
            ],
            
            // Symptoms Field
            Text(
              'Symptoms (Optional)',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            
            TextField(
              controller: _symptomsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Notes Field
            Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Any additional information...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _bookAppointment,
                child: _isBooking
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16.sp),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;
  final Doctor doctor;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.doctor,
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
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 16.h),
              
              Text(
                'Your appointment has been successfully booked.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 32.h),
              
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Doctor', doctor.name),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Specialization', doctor.specialization),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(booking.appointmentDate)),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Time', booking.appointmentTime),
                    SizedBox(height: 12.h),
                    _buildInfoRow('Status', 'Pending Confirmation'),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}