import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../theme/app_theme.dart';

class OtpField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;

  const OtpField({super.key, required this.controller, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 46,
      height: 54,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
    );
    return Pinput(
      length: 6,
      controller: controller,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: defaultTheme.copyWith(
        decoration: defaultTheme.decoration!.copyWith(
          border: Border.all(color: AppColors.primary, width: 1.6),
        ),
      ),
      onCompleted: onCompleted,
    );
  }
}
