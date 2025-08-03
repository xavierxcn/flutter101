import 'dart:ui';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends GetxService {
  static const String _storageKey = 'language_code';
  final _storage = GetStorage();

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  // Default locale
  static const Locale defaultLocale = Locale('en', 'US');

  // Current locale observable
  final Rx<Locale> _currentLocale = defaultLocale.obs;
  Locale get currentLocale => _currentLocale.value;

  @override
  void onInit() {
    super.onInit();
    _loadLocaleFromStorage();
  }

  /// Load saved locale from storage
  void _loadLocaleFromStorage() {
    final savedLanguageCode = _storage.read(_storageKey);
    if (savedLanguageCode != null) {
      final locale = _getLocaleFromLanguageCode(savedLanguageCode);
      if (locale != null) {
        _currentLocale.value = locale;
        Get.updateLocale(locale);
      }
    }
  }

  /// Get locale from language code
  Locale? _getLocaleFromLanguageCode(String languageCode) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }
    return null;
  }

  /// Change language
  void changeLanguage(String languageCode) {
    final locale = _getLocaleFromLanguageCode(languageCode);
    if (locale != null) {
      _currentLocale.value = locale;
      Get.updateLocale(locale);
      _storage.write(_storageKey, languageCode);

      // Show success message
      Get.snackbar(
        'success'.tr,
        'language_switched'.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Toggle between English and Chinese
  void toggleLanguage() {
    if (currentLocale.languageCode == 'en') {
      changeLanguage('zh');
    } else {
      changeLanguage('en');
    }
  }

  /// Get current language name
  String getCurrentLanguageName() {
    switch (currentLocale.languageCode) {
      case 'zh':
        return '中文';
      case 'en':
      default:
        return 'English';
    }
  }

  /// Get opposite language name (for toggle button)
  String getToggleLanguageName() {
    switch (currentLocale.languageCode) {
      case 'zh':
        return 'English';
      case 'en':
      default:
        return '中文';
    }
  }

  /// Check if current language is Chinese
  bool get isChineseLocale => currentLocale.languageCode == 'zh';

  /// Check if current language is English
  bool get isEnglishLocale => currentLocale.languageCode == 'en';
}
