import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/app_colors.dart';
import '../../../../core/services/email_otp_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// ==================== AUTH CONTROLLER ====================
class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // ==================== TEXT EDITING CONTROLLERS ====================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController resetEmailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // ==================== REACTIVE STATE ====================
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  final RxString pendingName = ''.obs;
  final RxString pendingEmail = ''.obs;
  final RxString pendingPassword = ''.obs;
  final RxString currentGeneratedOtp = ''.obs;

  bool get isLoggedIn => currentUser.value != null;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  // ==================== LIFECYCLE ====================
  @override
  void onInit() {
    super.onInit();
    currentUser.value = _repository.getCurrentUser();
    currentUser.bindStream(_repository.authStateChanges);
    if (currentUser.value != null) {
      _persistUserSession(currentUser.value!);
    } else {
      _restoreSavedUserSession();
    }
    currentUser.listen((user) {
      if (user != null) {
        _persistUserSession(user);
      }
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    resetEmailController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    resetEmailController.clear();
    otpController.clear();
  }

  // ==================== SESSION PERSISTENCE ====================
  Future<void> _persistUserSession(UserModel user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_email', user.email);
      if (user.name.isNotEmpty) {
        await prefs.setString('user_name', user.name);
      }
    } catch (e) {
      debugPrint('Session save note: $e');
    }
  }

  Future<void> _clearUserSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
    } catch (e) {
      debugPrint('Session clear note: $e');
    }
  }

  Future<void> _restoreSavedUserSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isLoggedInPref = prefs.getBool('is_logged_in') ?? false;
      final String? userId = prefs.getString('user_id');
      final String? userEmail = prefs.getString('user_email');
      final String? userName = prefs.getString('user_name');

      if (isLoggedInPref && userId != null && currentUser.value == null) {
        currentUser.value = UserModel(
          uid: userId,
          email: userEmail ?? '',
          name: userName ?? 'Player',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Session restore note: $e');
    }
  }

  // ==================== REGISTRATION & OTP ====================
  Future<bool> register({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
  }) async {
    final String cleanName = (name ?? nameController.text).trim();
    final String cleanEmail = (email ?? emailController.text).trim();
    final String cleanPass = password ?? passwordController.text;
    final String cleanConfirm = confirmPassword ?? confirmPasswordController.text;

    if (cleanName.isEmpty) {
      _showErrorSnackbar('Name Required', 'Please enter your name.');
      return false;
    }
    if (cleanEmail.isEmpty || !cleanEmail.isEmail) {
      _showErrorSnackbar('Invalid Email', 'Please enter a valid email address.');
      return false;
    }
    if (cleanPass.length < 6) {
      _showErrorSnackbar('Weak Password', 'Password must be at least 6 characters.');
      return false;
    }
    if (cleanPass != cleanConfirm) {
      _showErrorSnackbar('Password Mismatch', 'Passwords do not match.');
      return false;
    }

    try {
      isLoading.value = true;

      final UserModel user = await _repository.register(
        name: cleanName,
        email: cleanEmail,
        password: cleanPass,
      );

      currentUser.value = user;
      await _persistUserSession(user);

      _showSuccessSnackbar('Welcome!', 'Account created successfully!');
      clearForm();
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      _showErrorSnackbar('Registration Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== OTP VERIFICATION ====================
  Future<bool> verifyOtp(String enteredOtp) async {
    final String cleanOtp = enteredOtp.trim();

    if (cleanOtp.length != 6) {
      _showErrorSnackbar('Invalid Code', 'Please enter the complete 6-digit OTP.');
      return false;
    }

    if (cleanOtp != currentGeneratedOtp.value) {
      _showErrorSnackbar(
        'Incorrect OTP',
        'The OTP you entered is incorrect. Please check your email or spam folder.',
      );
      return false;
    }

    try {
      isLoading.value = true;

      await _repository.register(
        name: pendingName.value,
        email: pendingEmail.value,
        password: pendingPassword.value,
      );

      await _repository.logout();

      _showSuccessSnackbar(
        'Account Confirmed!',
        'OTP verified successfully! Please log in with your password.',
      );

      passwordController.clear();
      otpController.clear();
      Get.offNamed(AppRoutes.login);
      return true;
    } catch (e) {
      _showErrorSnackbar('Verification Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== RESEND OTP ====================
  Future<void> resendOtp() async {
    if (pendingEmail.value.isEmpty) {
      _showErrorSnackbar('Notice', 'No registration in progress. Please register again.');
      return;
    }

    try {
      isLoading.value = true;
      final String newOtp = EmailOtpService.generateOtp();
      currentGeneratedOtp.value = newOtp;
      otpController.clear();

      await EmailOtpService.sendOtpEmail(
        recipientEmail: pendingEmail.value,
        recipientName: pendingName.value,
        otpCode: newOtp,
      );

      _showSuccessSnackbar(
        'OTP Re-sent!',
        'A new verification code has been sent to ${pendingEmail.value}. Check your inbox or spam.',
      );
    } catch (e) {
      _showErrorSnackbar('Resend Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== LOGIN ====================
  Future<bool> login({
    String? email,
    String? password,
  }) async {
    final String cleanEmail = (email ?? emailController.text).trim();
    final String cleanPass = password ?? passwordController.text;

    if (cleanEmail.isEmpty || !cleanEmail.isEmail) {
      _showErrorSnackbar('Invalid Email', 'Please enter a valid email address.');
      return false;
    }
    if (cleanPass.isEmpty) {
      _showErrorSnackbar('Password Required', 'Please enter your password.');
      return false;
    }

    try {
      isLoading.value = true;
      final UserModel user = await _repository.login(
        email: cleanEmail,
        password: cleanPass,
      );
      currentUser.value = user;

      await _persistUserSession(user);

      _showSuccessSnackbar('Welcome Back!', 'Logged in successfully!');
      clearForm();
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      _showErrorSnackbar('Login Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GOOGLE SIGN IN ====================
  Future<bool> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final UserModel user = await _repository.signInWithGoogle();
      currentUser.value = user;

      await _persistUserSession(user);

      _showSuccessSnackbar('Welcome!', 'Signed in with Google successfully!');
      clearForm();
      Get.offAllNamed(AppRoutes.home);
      return true;
    } catch (e) {
      _showErrorSnackbar('Google Sign-In Failed', e.toString());
      return false;
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ==================== PASSWORD RESET ====================
  Future<bool> sendPasswordReset([String? email]) async {
    final String cleanEmail = (email ?? resetEmailController.text).trim();
    if (cleanEmail.isEmpty || !cleanEmail.isEmail) {
      _showErrorSnackbar('Invalid Email', 'Please enter a valid email address.');
      return false;
    }

    try {
      isLoading.value = true;
      await _repository.sendPasswordResetEmail(cleanEmail);
      _showSuccessSnackbar(
        'Email Sent',
        'Password reset link has been sent to your email.',
      );
      resetEmailController.clear();
      return true;
    } catch (e) {
      _showErrorSnackbar('Reset Failed', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _repository.logout();
      currentUser.value = null;

      await _clearUserSession();

      clearForm();
      _showSuccessSnackbar('Signed Out', 'You have been logged out.');
      Get.offAllNamed(AppRoutes.welcome);
    } catch (e) {
      _showErrorSnackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== UPDATE PLAYER NAME ====================
  Future<bool> updateDisplayName(String newName) => updateUserName(newName);

  Future<bool> updateUserName(String newName) async {
    final String clean = newName.trim();
    if (clean.isEmpty) {
      _showErrorSnackbar('Invalid Name', 'Name cannot be empty.');
      return false;
    }

    try {
      if (currentUser.value != null) {
        final updated = currentUser.value!.copyWith(name: clean);
        currentUser.value = updated;
        await _persistUserSession(updated);

        try {
          _repository.getCurrentUser();
        } catch (_) {}

        _showSuccessSnackbar('Name Updated', 'Player name changed to "$clean"');
        return true;
      }
      return false;
    } catch (e) {
      _showErrorSnackbar('Update Failed', e.toString());
      return false;
    }
  }

  // ==================== SNACKBAR HELPERS ====================
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: const Color(0xFF131938),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF131938)),
    );
  }
}
