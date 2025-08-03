# 国际化开发指南

## 概述

Flutter101 项目使用 GetX 的国际化系统，支持中英文无缝切换。本指南将帮助开发者正确添加和管理多语言内容。

## 🏗️ 架构概览

### 核心组件

1. **AppTranslations** - 翻译资源管理
2. **LocalizationService** - 语言切换服务
3. **GetStorage** - 语言偏好持久化
4. **GetX .tr 扩展** - 简化的翻译调用

## 📝 添加新的翻译文本

### 1. 在 AppTranslations 中添加 Key

```dart
// lib/app/localization/app_translations.dart
'en_US': {
  'new_feature': 'New Feature',
  'new_feature_desc': 'Description of the new feature',
},
'zh_CN': {
  'new_feature': '新功能',
  'new_feature_desc': '新功能的描述',
},
```

### 2. 在 UI 中使用翻译

```dart
// 简单文本
Text('new_feature'.tr)

// 带样式的文本
Text(
  'new_feature'.tr,
  style: TextStyle(fontWeight: FontWeight.bold),
)

// 按钮文本
ElevatedButton(
  onPressed: () {},
  child: Text('new_feature'.tr),
)
```

### 3. 带参数的翻译

```dart
// 在 AppTranslations 中定义
'en_US': {
  'welcome_user': 'Welcome, @name!',
  'items_count': 'You have @count items',
},
'zh_CN': {
  'welcome_user': '欢迎，@name！',
  'items_count': '您有 @count 个项目',
},

// 在代码中使用
Text('welcome_user'.trParams({'name': 'John'}))
Text('items_count'.trParams({'count': '5'}))
```

## 🎮 在 Controller 中使用国际化

### 基本用法

```dart
class MyController extends GetxController {
  final LocalizationService _localizationService = Get.find<LocalizationService>();
  
  void showSuccessMessage() {
    Get.snackbar(
      'success'.tr,
      'operation_completed'.tr,
    );
  }
  
  void toggleLanguage() {
    _localizationService.toggleLanguage();
  }
  
  String get currentLanguage => _localizationService.getCurrentLanguageName();
}
```

### 响应式语言状态

```dart
class MyController extends GetxController {
  // 监听语言变化
  @override
  void onInit() {
    super.onInit();
    
    // 监听 Locale 变化
    ever(Get.locale, (_) {
      // 语言变化时的回调
      update(); // 更新 UI
    });
  }
}
```

## 🖼️ 在 View 中使用国际化

### GetView 模式

```dart
class MyView extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_page'.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: controller.toggleLanguage,
            tooltip: 'switch_language'.tr,
          ),
        ],
      ),
      body: Column(
        children: [
          Text('welcome_message'.tr),
          ElevatedButton(
            onPressed: () {},
            child: Text('get_started'.tr),
          ),
        ],
      ),
    );
  }
}
```

### 响应式文本更新

```dart
// 使用 Obx 确保语言切换时文本立即更新
Obx(() => Text('dynamic_text'.tr))

// 对于复杂的文本组合
Obx(() => RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'hello'.tr),
      TextSpan(text: ' '),
      TextSpan(
        text: 'world'.tr,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
))
```

## 🛠️ LocalizationService 详解

### 核心方法

```dart
// 切换语言
localizationService.changeLanguage('zh'); // 切换到中文
localizationService.changeLanguage('en'); // 切换到英文

// 一键切换
localizationService.toggleLanguage(); // 在中英文间切换

// 获取当前语言信息
String currentLang = localizationService.getCurrentLanguageName(); // "中文" 或 "English"
String toggleLang = localizationService.getToggleLanguageName(); // 要切换到的语言名
bool isChinese = localizationService.isChineseLocale;
bool isEnglish = localizationService.isEnglishLocale;
```

### 持久化存储

```dart
// 用户的语言偏好会自动保存到本地存储
// 应用重启后会自动恢复用户选择的语言

// 存储 key: 'language_code'
// 支持的值: 'en', 'zh'
```

## 📋 翻译 Key 命名规范

### 命名约定

```dart
// ✅ 推荐的命名方式
'home_title'           // 页面标题
'home_welcome_message' // 页面特定消息
'button_save'          // 通用按钮
'error_network'        // 错误消息
'success_saved'        // 成功消息

// ❌ 避免的命名方式
'homeTitle'            // 驼峰命名
'HOME_TITLE'           // 全大写
'home.title'           // 点号分隔
'home/title'           // 斜杠分隔
```

### 分类组织

```dart
// 按功能模块分组
Map<String, Map<String, String>> get keys => {
  'en_US': {
    // App 级别
    'app_name': 'Flutter101',
    'app_version': 'Version 1.0.0',
    
    // 首页相关
    'home_title': 'Home',
    'home_welcome': 'Welcome',
    
    // 设置相关
    'settings_title': 'Settings',
    'settings_language': 'Language',
    'settings_theme': 'Theme',
    
    // 通用操作
    'action_save': 'Save',
    'action_cancel': 'Cancel',
    'action_delete': 'Delete',
    
    // 状态消息
    'status_loading': 'Loading...',
    'status_success': 'Success',
    'status_error': 'Error',
  },
};
```

## 🎯 最佳实践

### 1. 翻译完整性检查

```dart
// 创建脚本检查所有 key 是否都有对应翻译
void checkTranslationCompleteness() {
  final translations = AppTranslations().keys;
  final englishKeys = translations['en_US']!.keys.toSet();
  final chineseKeys = translations['zh_CN']!.keys.toSet();
  
  final missingInChinese = englishKeys.difference(chineseKeys);
  final missingInEnglish = chineseKeys.difference(englishKeys);
  
  if (missingInChinese.isNotEmpty) {
    print('Missing Chinese translations: $missingInChinese');
  }
  
  if (missingInEnglish.isNotEmpty) {
    print('Missing English translations: $missingInEnglish');
  }
}
```

### 2. 文本长度考虑

```dart
// 考虑不同语言的文本长度差异
// 英文通常比中文短，设计 UI 时要考虑文本溢出

// ✅ 使用 Flexible 或 Expanded
Row(
  children: [
    Icon(Icons.info),
    SizedBox(width: 8),
    Expanded(
      child: Text('very_long_text_that_might_overflow'.tr),
    ),
  ],
)

// ✅ 使用 maxLines 和 overflow
Text(
  'long_description'.tr,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### 3. 复数形式处理

```dart
// 对于需要复数形式的文本，使用参数化方式
'en_US': {
  'items_count_zero': 'No items',
  'items_count_one': '1 item',
  'items_count_other': '@count items',
},
'zh_CN': {
  'items_count_zero': '没有项目',
  'items_count_one': '1个项目',
  'items_count_other': '@count个项目',
},

// 在代码中根据数量选择合适的文本
String getItemsCountText(int count) {
  if (count == 0) return 'items_count_zero'.tr;
  if (count == 1) return 'items_count_one'.tr;
  return 'items_count_other'.trParams({'count': count.toString()});
}
```

### 4. 日期和数字格式化

```dart
import 'package:intl/intl.dart';

class LocalizedFormatters {
  static String formatDate(DateTime date) {
    final locale = Get.locale?.languageCode ?? 'en';
    if (locale == 'zh') {
      return DateFormat('yyyy年MM月dd日').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
  
  static String formatNumber(double number) {
    final locale = Get.locale?.languageCode ?? 'en';
    return NumberFormat.currency(
      locale: locale == 'zh' ? 'zh_CN' : 'en_US',
      symbol: locale == 'zh' ? '¥' : '\$',
    ).format(number);
  }
}
```

## 🚀 添加新语言支持

### 1. 扩展 LocalizationService

```dart
// 添加新的 Locale
static const List<Locale> supportedLocales = [
  Locale('en', 'US'),
  Locale('zh', 'CN'),
  Locale('ja', 'JP'), // 添加日语支持
];

// 更新语言名称获取方法
String getCurrentLanguageName() {
  switch (currentLocale.languageCode) {
    case 'zh': return '中文';
    case 'ja': return '日本語';
    case 'en':
    default: return 'English';
  }
}
```

### 2. 添加翻译内容

```dart
// 在 AppTranslations 中添加新语言
'ja_JP': {
  'app_name': 'Flutter101',
  'welcome_title': 'Flutter101へようこそ！',
  // ... 其他翻译
},
```

## 🔧 调试和测试

### 1. 翻译测试

```dart
// 创建测试确保翻译正常工作
testWidgets('should display translated text', (tester) async {
  // 设置中文环境
  Get.testMode = true;
  Get.updateLocale(Locale('zh', 'CN'));
  
  await tester.pumpWidget(MyApp());
  
  // 验证中文文本显示
  expect(find.text('欢迎来到 Flutter101！'), findsOneWidget);
  
  // 切换到英文
  Get.updateLocale(Locale('en', 'US'));
  await tester.pump();
  
  // 验证英文文本显示
  expect(find.text('Welcome to Flutter101!'), findsOneWidget);
});
```

### 2. 缺失翻译检测

```dart
// 在开发模式下检测缺失的翻译
void main() {
  if (kDebugMode) {
    // 重写 .tr 方法来检测缺失的翻译
    // 这可以帮助开发者发现未翻译的文本
  }
  runApp(MyApp());
}
```

---

通过遵循这个指南，你可以确保项目的国际化功能健壮、一致且易于维护。记住始终为新添加的用户可见文本提供完整的翻译，并测试不同语言下的 UI 表现。