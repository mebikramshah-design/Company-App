import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/otp_field.dart';

class GmailOtpScreen extends StatefulWidget {
  const GmailOtpScreen({super.key});

  @override
  State<GmailOtpScreen> createState() => _GmailOtpScreenState();
}

class _GmailOtpScreenState extends State<GmailOtpScreen> {
  final _otp = TextEditingController();
  bool _busy = false;

  String get _maskedEmail {
    final email = context.read<AuthService>().pendingGuestEmail ?? 'you@gmail.com';
    final at = email.indexOf('@');
    if (at <= 2) return email;
    return '${email.substring(0, 2)}****${email.substring(at)}';
  }

  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      await context.read<AuthService>().verifyGuestOtp(_otp.text.trim());
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
            child: const Icon(Icons.mark_email_read,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            'Check Your Gmail',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              children: [
                const TextSpan(text: 'We sent a 6-digit verification code to\n'),
                TextSpan(
                  text: _maskedEmail,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
                : const Text('Verify & Continue'),
          ),
          const SizedBox(height: 14),
          const Text(
            "Didn't receive the code? Resend in 47s",
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 28),
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
                  "Didn't get the email?",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text('• Check your spam / junk folder',
                    style: TextStyle(fontSize: 12, height: 1.6)),
                Text('• Make sure you entered the correct Gmail',
                    style: TextStyle(fontSize: 12, height: 1.6)),
                Text('• The code expires in 10 minutes',
                    style: TextStyle(fontSize: 12, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
