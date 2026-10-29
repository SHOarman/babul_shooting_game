import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/welcome_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/reg_page.dart';
import '../../features/auth/presentation/verify_email_page.dart';
import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/home/presentation/babulgame_page.dart';

// ==================== APP PAGES & ROUTES CONFIG ====================
class AppPages {
  static const String initial = AppRoutes.welcome;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.game,
      page: () => const BabulgamePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
