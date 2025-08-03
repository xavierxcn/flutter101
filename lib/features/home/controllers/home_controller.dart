import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/welcome_message.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/utils/app_utils.dart';
import '../../../app/core/services/localization_service.dart';

class HomeController extends GetxController with StateMixin<WelcomeMessage> {
  final ApiService _apiService = Get.find<ApiService>();
  final LocalizationService _localizationService =
      Get.find<LocalizationService>();

  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  // Language getters
  String get currentLanguageName =>
      _localizationService.getCurrentLanguageName();
  String get toggleLanguageName => _localizationService.getToggleLanguageName();

  @override
  void onInit() {
    super.onInit();
    loadWelcomeMessage();
  }

  void loadWelcomeMessage() async {
    try {
      change(null, status: RxStatus.loading());

      final welcomeMessage = await _apiService.getWelcomeMessage();

      change(welcomeMessage, status: RxStatus.success());

      AppUtils.showSuccessSnackbar(
        title: 'success'.tr,
        message: 'welcome_loaded'.tr,
      );
    } catch (e) {
      change(
        null,
        status: RxStatus.error('Failed to load welcome message: $e'),
      );

      AppUtils.showErrorSnackbar(
        title: 'error'.tr,
        message: 'failed_to_load'.tr,
      );
    }
  }

  void refreshData() {
    loadWelcomeMessage();
  }

  void simulateError() async {
    try {
      change(null, status: RxStatus.loading());
      await _apiService.getWelcomeMessageWithError();
    } catch (e) {
      change(null, status: RxStatus.error('Simulated error: $e'));

      AppUtils.showErrorSnackbar(
        title: 'error'.tr,
        message: 'simulated_error'.tr,
      );
    }
  }

  void toggleTheme() {
    _isDarkMode.toggle();
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    final modeText = _isDarkMode.value ? 'dark'.tr : 'light'.tr;
    AppUtils.showSnackbar(
      title: 'theme_management'.tr,
      message: 'theme_switched'.trParams({'mode': modeText}),
    );
  }

  void toggleLanguage() {
    _localizationService.toggleLanguage();
  }
}
