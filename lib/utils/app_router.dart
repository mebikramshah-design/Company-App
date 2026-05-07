import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_selection_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/guest_login_screen.dart';
import '../screens/auth/gmail_otp_screen.dart';
import '../screens/auth/employee_register_screen.dart';
import '../screens/auth/sms_otp_screen.dart';
import '../screens/main_shell.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(
        path: '/login-selection',
        builder: (_, __) => const LoginSelectionScreen(),
      ),
      GoRoute(path: '/guest', builder: (_, __) => const GuestLoginScreen()),
      GoRoute(path: '/guest/otp', builder: (_, __) => const GmailOtpScreen()),
      GoRoute(
        path: '/employee/register',
        builder: (_, __) => const EmployeeRegisterScreen(),
      ),
      GoRoute(
        path: '/employee/otp',
        builder: (_, __) => const SmsOtpScreen(),
      ),
      GoRoute(path: '/home', builder: (_, __) => const MainShell()),
    ],
  );
}
