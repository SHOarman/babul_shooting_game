import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'widgets/circular_back_button.dart';
import 'widgets/game_primary_button.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AuthController _authController = Get.find<AuthController>();
  final List<TextEditingController> _digitControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _resendCountdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _digitControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getEnteredOtp() {
    return _digitControllers.map((c) => c.text).join();
  }

  void _handleVerify() {
    final otp = _getEnteredOtp();
    _authController.verifyOtp(otp);
  }

  void _handleResend() {
    if (_resendCountdown == 0) {
      _authController.resendOtp();
      _startTimer();
      for (var c in _digitControllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF131938);
    const Color subtitleColor = Color(0xFF98A7C7);
    const Color linkYellow = Color(0xFFFDBB3A);
    const Color boxFillColor = Color(0xFF1B2247);
    const Color borderColor = Color(0xFF2C3766);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= Circular Back Button =================
              CircularBackButton(
                onTap: () => Get.offNamed(AppRoutes.login),
              ),

              const SizedBox(height: 24),

              // ================= Icon Badge =================
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: linkYellow.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: linkYellow.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: linkYellow,
                    size: 46,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ================= Title & Subtitle =================
              const Center(
                child: Text(
                  'Enter 6-Digit OTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Obx(
                  () => Text(
                    'We sent an OTP code to:\n${_authController.pendingEmail.value.isNotEmpty ? _authController.pendingEmail.value : 'your email'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Spam Folder Warning
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2247),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF283464)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: linkYellow, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Check your Inbox or Spam folder for the OTP email.',
                        style: TextStyle(color: Color(0xFFB0BFDE), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= 6 OTP INPUT BOXES =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextFormField(
                      controller: _digitControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: boxFillColor,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: linkYellow, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_getEnteredOtp().length == 6) {
                          _handleVerify();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // ================= Verify Button =================
              Obx(
                () => GamePrimaryButton(
                  text: 'Verify & Confirm',
                  isLoading: _authController.isLoading.value,
                  onTap: _handleVerify,
                ),
              ),

              const SizedBox(height: 20),

              // ================= Resend OTP Section =================
              Center(
                child: _resendCountdown > 0
                    ? Text(
                        'Resend code in $_resendCountdown seconds',
                        style: const TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : TextButton.icon(
                        onPressed: _handleResend,
                        icon: const Icon(Icons.refresh_rounded, color: linkYellow, size: 18),
                        label: const Text(
                          'Resend OTP Code',
                          style: TextStyle(
                            color: linkYellow,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // ================= Back to Login =================
              Center(
                child: TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.login),
                  child: const Text(
                    'Back to Log in',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: subtitleColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
