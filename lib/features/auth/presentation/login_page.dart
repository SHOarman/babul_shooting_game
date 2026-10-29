import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/circular_back_button.dart';
import 'widgets/game_primary_button.dart';
import 'widgets/google_auth_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller call via Dependency Injection
    final AuthController authController = Get.find<AuthController>();

    const Color backgroundColor = Color(0xFF131938);
    const Color subtitleColor = Color(0xFF98A7C7);
    const Color linkYellow = Color(0xFFFDBB3A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= Circular Back Button =================
              const CircularBackButton(),

              const SizedBox(height: 28),

              // ================= Header Section =================
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue your bubble pop adventure',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // ================= Form Fields =================
              // 1. Email Field
              AuthTextField(
                label: 'Email',
                hintText: 'you@example.com',
                controller: authController.emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // 2. Password Field (Reactive obscureText)
              Obx(
                () => AuthTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: authController.passwordController,
                  obscureText: authController.isPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.isPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF6F7D9F),
                      size: 20,
                    ),
                    onPressed: authController.togglePasswordVisibility,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: linkYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ================= Primary Login Button =================
              Obx(
                () => GamePrimaryButton(
                  text: 'Log in',
                  isLoading: authController.isLoading.value,
                  onTap: authController.login,
                ),
              ),

              const SizedBox(height: 14),

              // ================= Google Auth Button =================
              Obx(
                () => GoogleAuthButton(
                  text: 'Continue with Google',
                  isLoading: authController.isGoogleLoading.value,
                  onTap: authController.isGoogleLoading.value ? null : authController.signInWithGoogle,
                ),
              ),

              const SizedBox(height: 26),

              // ================= Bottom Navigation Link =================
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.register),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: subtitleColor),
                        ),
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: linkYellow,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                            decorationColor: linkYellow,
                            decorationThickness: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
