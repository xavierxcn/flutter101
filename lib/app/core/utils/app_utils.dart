import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppUtils {
  // Loading dialog
  static void showLoading({String? message}) {
    Get.dialog(
      AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Show snackbar
  static void showSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor ?? Colors.black87,
      colorText: colorText ?? Colors.white,
      duration: duration ?? const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Show error snackbar
  static void showErrorSnackbar({
    required String title,
    required String message,
  }) {
    showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Show success snackbar
  static void showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Validate email
  static bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return GetUtils.isPhoneNumber(phone);
  }
}
