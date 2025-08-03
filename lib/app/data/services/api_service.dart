import 'package:get/get.dart';
import '../models/welcome_message.dart';

class ApiService extends GetxService {
  // final NetworkService _networkService = Get.find<NetworkService>();

  // Simulate fetching welcome message
  Future<WelcomeMessage> getWelcomeMessage() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, we'll return mock data
      // In a real app, you would make an actual API call like:
      // final response = await _networkService.get('/welcome');
      // return WelcomeMessage.fromJson(response.data);

      return const WelcomeMessage(
        title: 'Welcome to Flutter101!',
        message:
            'This is a modern Flutter app built with GetX architecture. '
            'It demonstrates state management, dependency injection, and routing.',
        isVisible: true,
      );
    } catch (e) {
      Get.log('Error fetching welcome message: $e');
      rethrow;
    }
  }

  // Simulate error scenario
  Future<WelcomeMessage> getWelcomeMessageWithError() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Failed to load welcome message');
  }
}
