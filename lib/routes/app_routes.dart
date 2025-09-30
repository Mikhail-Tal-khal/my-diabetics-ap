import 'package:flutter/material.dart';
import 'package:my_diabeticapp/screens/auth/forgot_password_screen.dart';
import 'package:my_diabeticapp/screens/auth/login_screen.dart';
import 'package:my_diabeticapp/screens/auth/signup_screen.dart';
import 'package:my_diabeticapp/screens/detection/diabetes_detection_screen.dart' show DiabetesDetectionScreen;
import 'package:my_diabeticapp/screens/doctor_consultation/doctor_consultation_screen.dart';
import 'package:my_diabeticapp/screens/home/history_screen.dart';
import 'package:my_diabeticapp/screens/home/home_screen.dart';
import 'package:my_diabeticapp/screens/splash/splash_screen.dart';
import 'package:my_diabeticapp/screens/welcome/welcome_screen.dart';

class AppRoutes {
  // Existing routes...
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String detection = '/detection';
  static const String history = '/history';
  static const String doctorConsultation = '/doctor-consultation';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Existing cases...
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case detection:
        return MaterialPageRoute(
          builder: (_) => const DiabetesDetectionScreen(),
        );
      case doctorConsultation:
        return MaterialPageRoute(
          builder: (_) => const DoctorConsultationScreen(),
        );
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
