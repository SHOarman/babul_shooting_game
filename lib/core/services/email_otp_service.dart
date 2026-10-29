import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailOtpService {
  static String? _currentOtp;
  static DateTime? _otpExpiry;

  /// Generate a fresh 6-digit OTP code (100000 - 999999)
  static String generateOtp() {
    final int code = Random().nextInt(900000) + 100000;
    _currentOtp = code.toString();
    _otpExpiry = DateTime.now().add(const Duration(minutes: 10));
    return _currentOtp!;
  }

  /// Get current active OTP
  static String? get currentOtp => _currentOtp;

  /// Verify entered OTP
  static bool verifyOtp(String inputOtp) {
    if (_currentOtp == null || _otpExpiry == null) return false;
    if (DateTime.now().isAfter(_otpExpiry!)) return false;
    return inputOtp.trim() == _currentOtp;
  }

  /// Send OTP to user's email address
  static Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String recipientName,
    required String otpCode,
  }) async {
    // Prominent console print using both print() and debugPrint() so it always shows in all terminals
    // ignore: avoid_print
    print('\n================================================================');
    // ignore: avoid_print
    print(' 🔥🔥🔥 BABUL GAME OTP VERIFICATION CODE 🔥🔥🔥');
    // ignore: avoid_print
    print(' 📧 Recipient Email : $recipientEmail');
    // ignore: avoid_print
    print(' 🔑 6-Digit OTP Code: >>> $otpCode <<<');
    // ignore: avoid_print
    print('================================================================\n');

    final String senderEmail = (dotenv.env['SMTP_EMAIL'] ?? '').trim();
    final String senderPassword = (dotenv.env['SMTP_PASSWORD'] ?? '').trim();

    // If SMTP credentials exist in .env, send real email via Gmail SMTP
    if (senderEmail.isNotEmpty && senderPassword.isNotEmpty) {
      try {
        debugPrint('[SMTP] Attempting to send email from $senderEmail to $recipientEmail...');
        final smtpServer = gmail(senderEmail, senderPassword);
        final message = Message()
          ..from = Address(senderEmail, 'Babul Game')
          ..recipients.add(recipientEmail.trim())
          ..subject = '$otpCode is your Babul Game OTP Code'
          ..html = '''
            <div style="font-family: Arial, sans-serif; background-color: #131938; color: #ffffff; padding: 25px; border-radius: 12px; max-width: 500px; margin: auto;">
              <h1 style="color: #FDBB3A; text-align: center; margin-bottom: 6px;">Babul Game</h1>
              <h2 style="color: #ffffff; text-align: center; margin-top: 0;">Account Verification</h2>
              <p style="color: #A2B0D0; font-size: 15px; text-align: center;">Hello <b>$recipientName</b>, use the 6-digit OTP code below to confirm your account:</p>
              <div style="background-color: #1C2348; border: 2px dashed #FDBB3A; border-radius: 10px; padding: 18px; text-align: center; margin: 24px 0;">
                <span style="font-size: 38px; font-weight: bold; letter-spacing: 8px; color: #FDBB3A;">$otpCode</span>
              </div>
              <p style="color: #7482A6; font-size: 13px; text-align: center;">This code is valid for 10 minutes.</p>
              <p style="color: #FDBB3A; font-size: 12px; text-align: center; margin-top: 15px;">
                <i>Note: If you don't see this in your Inbox, please check your <b>Spam / Junk</b> folder!</i>
              </p>
            </div>
          ''';

        final sendReport = await send(message, smtpServer);
        // ignore: avoid_print
        print('[SMTP SUCCESS] Email sent successfully to $recipientEmail! Report: $sendReport');
        return true;
      } catch (e) {
        // ignore: avoid_print
        print('[SMTP ERROR] Failed to send email via SMTP: $e');
        return false;
      }
    } else {
      // ignore: avoid_print
      print('[SMTP NOTICE] No SMTP_EMAIL or SMTP_PASSWORD found in .env.');
      // ignore: avoid_print
      print('[SMTP NOTICE] To deliver real emails, add SMTP_EMAIL and SMTP_PASSWORD in .env');
      return true;
    }
  }
}
