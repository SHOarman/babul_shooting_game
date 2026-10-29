import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/circular_back_button.dart';
import 'widgets/game_primary_button.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
                'Reset Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email address and we will send you a link to reset your password',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              // ================= Form Field =================
              AuthTextField(
                label: 'Email',
                hintText: 'you@example.com',
                controller: authController.resetEmailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 32),

              // ================= Primary Button =================
              Obx(
                () => GamePrimaryButton(
                  text: 'Send Reset Link',
                  isLoading: authController.isLoading.value,
                  onTap: authController.sendPasswordReset,
                ),
              ),

              const SizedBox(height: 24),

              // ================= Back to Login Link =================
              Center(
                child: TextButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18, color: linkYellow),
                  label: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: linkYellow,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
