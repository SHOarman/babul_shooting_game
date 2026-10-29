import 'package:flutter/material.dart';

// ==================== LEVEL BOX WIDGET ====================
class CustomLevelBox extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final bool isLocked;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomLevelBox({
    super.key,
    required this.levelNumber,
    this.stars = 0,
    this.isLocked = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color unlockedBg = Color(0xFF20295A);
    const Color lockedBg = Color(0xFF151B3D);
    const Color selectedBorderColor = Color(0xFFFFD043);
    const Color starFilledColor = Color(0xFFFFD043);
    const Color starUnfilledColor = Color(0xFF384370);
    const Color lockedNumberColor = Color(0xFF455280);
    const Color lockedIconColor = Color(0xFF5A6A9B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isLocked ? lockedBg : unlockedBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? selectedBorderColor
                  : (isLocked ? Colors.transparent : Colors.white.withValues(alpha: 0.05)),
              width: isSelected ? 2.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedBorderColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$levelNumber',
                style: TextStyle(
                  color: isLocked ? lockedNumberColor : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              if (isLocked)
                const Icon(
                  Icons.lock_rounded,
                  color: lockedIconColor,
                  size: 22,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final bool isFilled = index < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: Icon(
                        Icons.star_rounded,
                        color: isFilled ? starFilledColor : starUnfilledColor,
                        size: 18,
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef CustomLavelBox = CustomLevelBox;
