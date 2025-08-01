import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';

class EmergencyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double? size;

  const EmergencyButton({
    super.key,
    this.onPressed,
    this.size,
  });

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size ?? 60.w;

    return GestureDetector(
      onTapDown: (_) {
        _animationController.stop();
        setState(() {});
      },
      onTapUp: (_) {
        _animationController.repeat(reverse: true);
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        _animationController.repeat(reverse: true);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect
              Container(
                width: buttonSize * _pulseAnimation.value,
                height: buttonSize * _pulseAnimation.value,
                decoration: BoxDecoration(
                  color: AppConstants.emergencyColor.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              
              // Main button
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: AppConstants.emergencyColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.emergencyColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: buttonSize * 0.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LargeEmergencyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const LargeEmergencyButton({
    super.key,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.emergencyColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppConstants.emergencyColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emergency,
              size: 40.sp,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Text(
              text ?? 'EMERGENCY',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Tap for immediate help',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}