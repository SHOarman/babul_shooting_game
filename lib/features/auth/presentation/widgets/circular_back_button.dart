import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircularBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CircularBackButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => Get.back(),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFF232C58),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Padding(
            padding: EdgeInsets.only(left: 6.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

