import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popupgame/core/services/sound_service.dart';
import 'package:popupgame/features/home/presentation/controllers/home_controller.dart';

// ==================== DRAWER SETTINGS SECTION WIDGET ====================
class DrawerSettingsSection extends StatelessWidget {
  final HomeController controller;

  const DrawerSettingsSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardBg = Color(0xFF181F46);
    const Color subtitleColor = Color(0xFF8E9CB8);
    const Color goldenYellow = Color(0xFFFFD043);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SETTINGS & PREFERENCES',
          style: TextStyle(
            color: subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF253062), width: 1),
          ),
          child: Obx(
            () => SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SoundService.isSoundEnabled.value
                      ? goldenYellow.withValues(alpha: 0.18)
                      : const Color(0xFF28345E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  SoundService.isSoundEnabled.value
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: SoundService.isSoundEnabled.value
                      ? goldenYellow
                      : const Color(0xFF6B7B9E),
                  size: 22,
                ),
              ),
              title: const Text(
                'Sound Effects',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                SoundService.isSoundEnabled.value ? 'Enabled' : 'Muted',
                style: const TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeThumbColor: goldenYellow,
              activeTrackColor: goldenYellow.withValues(alpha: 0.40),
              inactiveThumbColor: const Color(0xFF6B7B9E),
              inactiveTrackColor: const Color(0xFF1E2648),
              value: SoundService.isSoundEnabled.value,
              onChanged: (val) {
                SoundService.isSoundEnabled.value = val;
                if (val) SoundService.playPop();
              },
            ),
          ),
        ),
      ],
    );
  }
}
