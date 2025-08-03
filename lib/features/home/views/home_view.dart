import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../app/data/models/welcome_message.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          // Language toggle button
          Obx(
            () => IconButton(
              icon: const Icon(Icons.language),
              onPressed: controller.toggleLanguage,
              tooltip:
                  '${'switch_language'.tr} (${controller.toggleLanguageName})',
            ),
          ),
          // Theme toggle button
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: controller.toggleTheme,
              tooltip: controller.isDarkMode ? 'light'.tr : 'dark'.tr,
            ),
          ),
        ],
      ),
      body: controller.obx(
        (welcomeMessage) => _buildSuccessContent(welcomeMessage!),
        onLoading: _buildLoadingContent(),
        onError: (error) => _buildErrorContent(error!),
        onEmpty: _buildEmptyContent(),
      ),
    );
  }

  Widget _buildSuccessContent(WelcomeMessage welcomeMessage) {
    return RefreshIndicator(
      onRefresh: () async => controller.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'welcome_title'.tr,
                      style: Get.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('welcome_message'.tr, style: Get.textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Get.theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'status_active'.tr,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Features Section
            Text(
              'features_title'.tr,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureCard(
              icon: Icons.architecture,
              title: 'getx_architecture'.tr,
              description: 'getx_architecture_desc'.tr,
            ),

            _buildFeatureCard(
              icon: Icons.network_check,
              title: 'network_service'.tr,
              description: 'network_service_desc'.tr,
            ),

            _buildFeatureCard(
              icon: Icons.data_object,
              title: 'freezed_models'.tr,
              description: 'freezed_models_desc'.tr,
            ),

            _buildFeatureCard(
              icon: Icons.palette,
              title: 'theme_management'.tr,
              description: 'theme_management_desc'.tr,
            ),

            _buildFeatureCard(
              icon: Icons.language,
              title: 'internationalization'.tr,
              description: 'internationalization_desc'.tr,
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Text(
              'actions_title'.tr,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.refreshData,
                    icon: const Icon(Icons.refresh),
                    label: Text('refresh'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.simulateError,
                    icon: const Icon(Icons.error_outline),
                    label: Text('test_error'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Get.theme.primaryColor),
        ),
        title: Text(
          title,
          style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description, style: Get.textTheme.bodyMedium),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('loading_message'.tr),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'error_title'.tr,
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshData,
              icon: const Icon(Icons.refresh),
              label: Text('try_again'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_data'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
