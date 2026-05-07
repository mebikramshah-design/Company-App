import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/otp_field.dart';

class SmsOtpScreen extends StatefulWidget {
  const SmsOtpScreen({super.key});

  @override
  State<SmsOtpScreen> createState() => _SmsOtpScreenState();
}

class _SmsOtpScreenState extends State<SmsOtpScreen> {
  final _otp = TextEditingController();
  bool _busy = false;

  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      await context
          .read<AuthService>()
          .verifyEmployeeMobileOtp(_otp.text.trim());
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.smartphone,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            'Verify Your Mobile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              children: [
                const TextSpan(text: 'Welcome, '),
                TextSpan(
                  text: user?.displayName ?? 'Employee',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '!\nA 6-digit SMS code was sent to\n'),
                TextSpan(
                  text: user?.mobile ?? '+974 ****3456',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          if (user?.employeeId != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_outlined,
                      size: 14, color: AppColors.navy),
                  const SizedBox(width: 6),
                  Text(
                    'Employee ID: ${user!.employeeId}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          OtpField(controller: _otp, onCompleted: (_) => _verify()),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: _busy ? null : _verify,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Verify & Complete Registration'),
          ),
          const SizedBox(height: 12),
          const Text(
            "Didn't receive the SMS? Resend in 52s",
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registration Steps',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                _Step(label: 'Account details entered', done: true),
                _Step(label: 'Mobile verification', current: true),
                _Step(label: 'Account activated'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool done;
  final bool current;
  const _Step(
      {required this.label, this.done = false, this.current = false});

  @override
  Widget build(BuildContext context) {
    final color = done
        ? Colors.green
        : (current ? AppColors.primary : AppColors.textMuted);
    final icon = done
        ? Icons.check_circle
        : (current ? Icons.radio_button_checked : Icons.radio_button_unchecked);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: done || current ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
