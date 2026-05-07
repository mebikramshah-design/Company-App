import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';

class EmployeeRegisterScreen extends StatefulWidget {
  const EmployeeRegisterScreen({super.key});

  @override
  State<EmployeeRegisterScreen> createState() => _EmployeeRegisterScreenState();
}

class _EmployeeRegisterScreenState extends State<EmployeeRegisterScreen> {
  final _name = TextEditingController();
  final _empId = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _empId.dispose();
    _mobile.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  double _strength() {
    final p = _password.text;
    var s = 0.0;
    if (p.length >= 6) s += 0.25;
    if (p.length >= 10) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(p) && RegExp(r'[^A-Za-z0-9]').hasMatch(p)) {
      s += 0.25;
    }
    return s;
  }

  Future<void> _submit() async {
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AuthService>().registerEmployee(
            fullName: _name.text.trim(),
            employeeId: _empId.text.trim(),
            mobile: _mobile.text.trim(),
            password: _password.text,
          );
      if (mounted) context.push('/employee/otp');
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
    final strength = _strength();
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.business, size: 14, color: AppColors.navy),
                  SizedBox(width: 6),
                  Text(
                    'Internal Employee',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Employee Registration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Create your Darwish Interserve account. Your mobile\nwill be verified by SMS.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 22),
          const _Label('Full Name'),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Mohammed Al-Mansoori',
            ),
          ),
          const SizedBox(height: 14),
          const _Label('Employee ID'),
          TextField(
            controller: _empId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.badge_outlined),
              hintText: 'e.g. DI-2024-001',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Provided by HR — check your onboarding letter',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          const _Label('Mobile Number'),
          TextField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: '+974 3312 3456',
            ),
          ),
          const SizedBox(height: 14),
          const _Label('Password'),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 6,
              backgroundColor: const Color(0xFFE5E7EB),
              color: strength < 0.5
                  ? Colors.red
                  : (strength < 0.75 ? Colors.orange : Colors.green),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strength < 0.5
                ? 'Weak'
                : (strength < 0.75 ? 'Okay' : 'Good'),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          const _Label('Confirm Password'),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock_outline),
              hintText: 'Re-enter your password',
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Create Account & Verify Mobile'),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
