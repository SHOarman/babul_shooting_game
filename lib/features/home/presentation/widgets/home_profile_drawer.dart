import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import 'drawer/drawer_header_profile.dart';
import 'drawer/drawer_logout_button.dart';
import 'drawer/drawer_settings_section.dart';
import 'drawer/drawer_stats_dashboard.dart';

// ==================== HOME PROFILE DRAWER ====================
class HomeProfileDrawer extends StatelessWidget {
  final HomeController controller;

  const HomeProfileDrawer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color drawerBg = Color(0xFF0F132E);

    return Drawer(
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeaderProfile(
              authController: controller.authController,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DrawerStatsDashboard(controller: controller),
                  const SizedBox(height: 20),
                  DrawerSettingsSection(controller: controller),
                ],
              ),
            ),
            DrawerLogoutButton(controller: controller),
          ],
        ),
      ),
    );
  }
}
