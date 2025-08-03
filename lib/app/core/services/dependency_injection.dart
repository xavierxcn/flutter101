import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'network_service.dart';
import 'localization_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize GetStorage
    await GetStorage.init();

    // Core Services
    Get.putAsync(() => NetworkService().init());
    Get.putAsync(() => LocalizationService().init());
  }
}

extension GetxServiceExtension on GetxService {
  Future<GetxService> init() async {
    return this;
  }
}
