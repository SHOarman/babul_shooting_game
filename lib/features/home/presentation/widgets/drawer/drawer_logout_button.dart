import 'package:flutter/material.dart';
import 'package:popupgame/features/home/presentation/controllers/home_controller.dart';
import 'drawer_dialogs.dart';

// ==================== DRAWER LOGOUT BUTTON WIDGET ====================
class DrawerLogoutButton extends StatelessWidget {
  final HomeController controller;

  const DrawerLogoutButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF331525),
            foregroundColor: const Color(0xFFFF5252),
            side: const BorderSide(color: Color(0xFF6E2338), width: 1.2),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          onPressed: () => DrawerDialogs.showLogoutConfirmDialog(
            context,
            controller.authController.logout,
          ),
        ),
      ),
    );
  }
}
