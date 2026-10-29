import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart';
import 'core/routing/app_pages.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';

// ==================== APP INITIALIZATION ====================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env note: $e");
  }

  await DependencyInjection.init();

  String initialRoute = AppRoutes.welcome;
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final User? firebaseUser = FirebaseAuth.instance.currentUser;

    if (isLoggedIn || firebaseUser != null) {
      initialRoute = AppRoutes.home;
      if (firebaseUser != null) {
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', firebaseUser.uid);
      }
    }
  } catch (e) {
    debugPrint("Auto-login session check: $e");
  }

  runApp(MyApp(initialRoute: initialRoute));
}

// ==================== ROOT APPLICATION WIDGET ====================
class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = AppRoutes.welcome});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Babul Shooting',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
