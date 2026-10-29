import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/routing/app_routes.dart';
import 'widgets/game_primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF131938);
    const Color outlinedButtonBorder = Color(0xFF2E3966);
    const Color outlinedButtonBg = Color(0xFF161E42);
    const Color subtitleColor = Color(0xFFA5B4D4);
    const Color welcomeHeaderColor = Color(0xFF94A3C8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ================= BUBBLE GRAPHIC =================
              Image.asset(
                AppAssets.bubbleImage,
                height: 220,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 1),

              // ================= TEXT SECTION =================
              const Text(
                'WELCOME TO',
                style: TextStyle(
                  color: welcomeHeaderColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Babul Shooting',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Match colors, pop bubbles and beat all 10 levels',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ================= BUTTONS =================
              // 1. Get Started Button
              GamePrimaryButton(
                text: 'Get Started',
                onTap: () => Get.toNamed(AppRoutes.register),
              ),

              const SizedBox(height: 16),

              // 2. I Already Have an Account Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: outlinedButtonBg.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: outlinedButtonBorder,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'I Already Have an Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
