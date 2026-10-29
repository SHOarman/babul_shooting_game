import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:popupgame/features/auth/presentation/controllers/auth_controller.dart';
import 'drawer_dialogs.dart';

// ==================== DRAWER HEADER PROFILE WIDGET ====================
class DrawerHeaderProfile extends StatelessWidget {
  final AuthController authController;

  const DrawerHeaderProfile({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    const Color goldenYellow = Color(0xFFFFD043);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2254), Color(0xFF101538)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF263168), width: 1.2),
        ),
      ),
      child: Obx(() {
        final user = authController.currentUser.value;
        final String displayName = user?.name.isNotEmpty == true ? user!.name : 'Player';
        final String email = user?.email.isNotEmpty == true ? user!.email : 'player@gmail.com';
        final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P';
        final String uidShort = (user?.uid.isNotEmpty == true && user!.uid.length >= 8)
            ? user.uid.substring(0, 8)
            : 'Gamer';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD043), Color(0xFFFF8A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: goldenYellow.withValues(alpha: 0.40),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF14193C),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: goldenYellow,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => DrawerDialogs.showEditNameDialog(context, authController),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: goldenYellow.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: goldenYellow.withValues(alpha: 0.4), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, color: goldenYellow, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: goldenYellow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.alternate_email_rounded, size: 13, color: Color(0xFF8EA1CA)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9FB1D6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: user?.uid ?? ''));
                      Get.snackbar(
                        'Copied',
                        'User ID copied to clipboard!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF1E2850),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202A56),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ID: $uidShort',
                            style: const TextStyle(
                              color: Color(0xFF8BA0CE),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_rounded, size: 10, color: Color(0xFF8BA0CE)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
