import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _hospitalController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  UserType _selectedUserType = UserType.patient;
  String? _selectedSpecialization;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedUserType == UserType.patient) {
        await ref.read(authNotifierProvider.notifier).signUpPatient(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty 
              ? _phoneController.text.trim() 
              : null,
        );
      } else {
        await ref.read(authNotifierProvider.notifier).signUpDoctor(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          specialization: _selectedSpecialization ?? 'General Practice',
          phoneNumber: _phoneController.text.trim().isNotEmpty 
              ? _phoneController.text.trim() 
              : null,
          hospitalName: _hospitalController.text.trim().isNotEmpty 
              ? _hospitalController.text.trim() 
              : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        // Navigation will be handled by AuthWrapper
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              
              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios),
                padding: EdgeInsets.zero,
              ),
              
              SizedBox(height: 20.h),
              
              // Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                'Join ${AppConstants.appName} today',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // User Type Selection
              Text(
                'I am a:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildUserTypeCard(
                      userType: UserType.patient,
                      title: 'Patient',
                      icon: Icons.person,
                      isSelected: _selectedUserType == UserType.patient,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildUserTypeCard(
                      userType: UserType.doctor,
                      title: 'Doctor',
                      icon: Icons.medical_services,
                      isSelected: _selectedUserType == UserType.doctor,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Registration Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.requiredFieldError;
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.requiredFieldError;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return AppConstants.invalidEmailError;
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Doctor-specific fields
                    if (_selectedUserType == UserType.doctor) ...[
                      // Specialization Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSpecialization,
                        decoration: const InputDecoration(
                          labelText: 'Specialization',
                          prefixIcon: Icon(Icons.medical_information_outlined),
                        ),
                        items: AppConstants.medicalSpecializations.map((specialization) {
                          return DropdownMenuItem(
                            value: specialization,
                            child: Text(specialization),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecialization = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppConstants.requiredFieldError;
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      // Hospital Name
                      TextFormField(
                        controller: _hospitalController,
                        decoration: const InputDecoration(
                          labelText: 'Hospital/Clinic Name (Optional)',
                          prefixIcon: Icon(Icons.local_hospital_outlined),
                        ),
                      ),
                      
                      SizedBox(height: 16.h),
                    ],
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.requiredFieldError;
                        }
                        if (value.length < 6) {
                          return AppConstants.weakPasswordError;
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.requiredFieldError;
                        }
                        if (value != _passwordController.text) {
                          return AppConstants.passwordMismatchError;
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserType userType,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = userType;
          _selectedSpecialization = null; // Reset specialization when switching
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.animationDurationShort,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : AppConstants.textHintColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondaryColor,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}