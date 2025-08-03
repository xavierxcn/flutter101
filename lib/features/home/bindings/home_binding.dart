import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../app/data/services/api_service.dart';
import '../../../app/core/services/localization_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put services
    Get.lazyPut<ApiService>(() => ApiService());

    // Ensure localization service is available
    if (!Get.isRegistered<LocalizationService>()) {
      Get.lazyPut<LocalizationService>(() => LocalizationService());
    }

    // Put controller
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
