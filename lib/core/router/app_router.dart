import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/auth_choice_page.dart';
import '../../features/auth/presentation/pages/phone_login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/email_login_page.dart';
import '../../features/auth/presentation/pages/email_signup_page.dart';
import '../../features/cycle_tracking/presentation/pages/home_page.dart';
import '../../features/cycle_tracking/presentation/pages/log_period_page.dart';
import '../../features/cycle_tracking/presentation/pages/calendar_page.dart';
import '../../features/symptom_tracking/presentation/pages/log_symptom_page.dart';
import '../../features/asha_dashboard/presentation/pages/asha_dashboard_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth-choice',
        builder: (context, state) => const AuthChoicePage(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return OtpVerificationPage(
            verificationId: extra['verificationId']!,
            phoneNumber: extra['phoneNumber']!,
          );
        },
      ),
      GoRoute(
        path: '/email-login',
        builder: (context, state) => const EmailLoginPage(),
      ),
      GoRoute(
        path: '/email-signup',
        builder: (context, state) => const EmailSignupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/log-period',
        builder: (context, state) => const LogPeriodPage(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarPage(),
      ),
      GoRoute(
        path: '/log-symptom',
        builder: (context, state) => const LogSymptomPage(),
      ),
      GoRoute(
        path: '/asha-dashboard',
        builder: (context, state) => const AshaDashboardPage(),
      ),
    ],
  );
}
