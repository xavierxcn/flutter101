import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // English
    'en_US': {
      // App
      'app_name': 'Flutter101',
      'home': 'Home',

      // Home Screen
      'welcome_title': 'Welcome to Flutter101!',
      'welcome_message':
          'This is a modern Flutter app built with GetX architecture. '
          'It demonstrates state management, dependency injection, routing, and internationalization.',
      'status_active': 'Status: Active',

      // Features
      'features_title': 'Features Demonstrated',
      'getx_architecture': 'GetX Architecture',
      'getx_architecture_desc': 'State management with GetxController and obx',
      'network_service': 'Network Service',
      'network_service_desc': 'Dio integration with GetX dependency injection',
      'freezed_models': 'Freezed Models',
      'freezed_models_desc': 'Immutable data models with JSON serialization',
      'theme_management': 'Theme Management',
      'theme_management_desc': 'Dynamic theme switching with GetX',
      'internationalization': 'Internationalization',
      'internationalization_desc': 'Multi-language support with GetX',

      // Actions
      'actions_title': 'Actions',
      'refresh': 'Refresh',
      'test_error': 'Test Error',
      'switch_language': 'Switch Language',

      // States
      'loading': 'Loading...',
      'loading_message': 'Loading welcome message...',
      'error_title': 'Oops! Something went wrong',
      'try_again': 'Try Again',
      'no_data': 'No data available',

      // Messages
      'success': 'Success',
      'error': 'Error',
      'welcome_loaded': 'Welcome message loaded successfully!',
      'failed_to_load': 'Failed to load welcome message',
      'simulated_error': 'This is a simulated error!',
      'theme_switched': 'Switched to @mode mode',
      'language_switched': 'Language switched to English',
      'dark': 'Dark',
      'light': 'Light',
    },

    // Chinese
    'zh_CN': {
      // App
      'app_name': 'Flutter101',
      'home': '首页',

      // Home Screen
      'welcome_title': '欢迎来到 Flutter101！',
      'welcome_message':
          '这是一个基于 GetX 架构构建的现代化 Flutter 应用。'
          '它演示了状态管理、依赖注入、路由和国际化功能。',
      'status_active': '状态：活跃',

      // Features
      'features_title': '功能演示',
      'getx_architecture': 'GetX 架构',
      'getx_architecture_desc': '使用 GetxController 和 obx 进行状态管理',
      'network_service': '网络服务',
      'network_service_desc': 'Dio 与 GetX 依赖注入的集成',
      'freezed_models': 'Freezed 模型',
      'freezed_models_desc': '带有 JSON 序列化的不可变数据模型',
      'theme_management': '主题管理',
      'theme_management_desc': '使用 GetX 进行动态主题切换',
      'internationalization': '国际化',
      'internationalization_desc': '使用 GetX 实现多语言支持',

      // Actions
      'actions_title': '操作',
      'refresh': '刷新',
      'test_error': '测试错误',
      'switch_language': '切换语言',

      // States
      'loading': '加载中...',
      'loading_message': '正在加载欢迎消息...',
      'error_title': '哎呀！出了点问题',
      'try_again': '重试',
      'no_data': '暂无数据',

      // Messages
      'success': '成功',
      'error': '错误',
      'welcome_loaded': '欢迎消息加载成功！',
      'failed_to_load': '加载欢迎消息失败',
      'simulated_error': '这是一个模拟错误！',
      'theme_switched': '已切换到@mode模式',
      'language_switched': '语言已切换为中文',
      'dark': '深色',
      'light': '浅色',
    },
  };
}
