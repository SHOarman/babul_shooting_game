import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/circular_back_button.dart';
import 'widgets/game_primary_button.dart';
import 'widgets/google_auth_button.dart';

class RegPage extends StatelessWidget {
  const RegPage({super.key});

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

              const SizedBox(height: 24),

              // ================= Header Section =================
              const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign up to save your levels and stars',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 26),

              // ================= Form Fields =================
              // 1. Name
              AuthTextField(
                label: 'Name',
                hintText: 'Your name',
                controller: authController.nameController,
              ),

              const SizedBox(height: 18),

              // 2. Email
              AuthTextField(
                label: 'Email',
                hintText: 'you@example.com',
                controller: authController.emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // 3. Password
              Obx(
                () => AuthTextField(
                  label: 'Password',
                  hintText: 'At least 8 characters',
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

              const SizedBox(height: 18),

              // 4. Confirm Password
              Obx(
                () => AuthTextField(
                  label: 'Confirm password',
                  hintText: 'Re-enter password',
                  controller: authController.confirmPasswordController,
                  obscureText: authController.isConfirmPasswordHidden.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      authController.isConfirmPasswordHidden.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF6F7D9F),
                      size: 20,
                    ),
                    onPressed: authController.toggleConfirmPasswordVisibility,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ================= Primary Create Account Button =================
              Obx(
                () => GamePrimaryButton(
                  text: 'Create Account',
                  isLoading: authController.isLoading.value,
                  onTap: authController.register,
                ),
              ),

              const SizedBox(height: 14),

              // ================= Google Auth Button =================
              Obx(
                () => GoogleAuthButton(
                  text: 'Sign up with Google',
                  isLoading: authController.isGoogleLoading.value,
                  onTap: authController.isGoogleLoading.value ? null : authController.signInWithGoogle,
                ),
              ),

              const SizedBox(height: 24),

              // ================= Bottom Navigation Link =================
              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.login),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: subtitleColor),
                        ),
                        TextSpan(
                          text: 'Log in',
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
