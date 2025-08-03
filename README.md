# Flutter101 - GetX 架构脚手架

一个基于 GetX 生态系统的现代化 Flutter 项目脚手架，展示了最佳实践和完整的架构设计。

## 🏗️ 项目架构

### 核心技术栈

- **状态管理**: GetX (GetxController, Obx, StateMixin)
- **依赖注入**: GetX (Get.put, Get.lazyPut, Bindings)
- **路由系统**: GetX (GetMaterialApp, GetPage)
- **网络请求**: Dio
- **数据模型**: Freezed + json_annotation
- **国际化**: GetX Translations + LocalizationService
- **本地存储**: GetStorage
- **代码生成**: build_runner

### Feature-First 目录结构

```
lib/
├── app/
│   ├── core/
│   │   ├── services/        # 全局服务
│   │   │   ├── network_service.dart         # Dio 网络服务
│   │   │   ├── localization_service.dart    # 国际化服务
│   │   │   └── dependency_injection.dart    # 依赖注入配置
│   │   ├── utils/           # 工具类
│   │   │   └── app_utils.dart          # 通用工具方法
│   │   └── constants/       # 常量
│   │       └── app_constants.dart      # 应用常量
│   ├── data/
│   │   ├── models/          # Freezed 数据模型
│   │   │   └── welcome_message.dart    # 欢迎消息模型
│   │   └── services/        # API 服务
│   │       └── api_service.dart        # API 调用服务
│   ├── routes/              # 路由配置
│   │   ├── app_routes.dart             # 路由常量
│   │   └── app_pages.dart              # 路由页面配置
│   ├── theme/               # 主题配置
│   │   └── app_theme.dart              # 明暗主题配置
│   └── localization/        # 国际化配置
│       └── app_translations.dart       # 多语言翻译文件
└── features/                # 功能模块
    └── home/
        ├── controllers/     # GetxController
        │   └── home_controller.dart    # 首页控制器
        ├── views/           # UI 界面
        │   └── home_view.dart          # 首页视图
        └── bindings/        # 依赖绑定
            └── home_binding.dart       # 首页依赖绑定
```

## 🚀 功能特性

### 1. 完整的 GetX 架构演示

- **响应式状态管理**: 使用 `StateMixin<T>` 优雅处理异步状态（loading, success, error, empty）
- **依赖注入**: 通过 `Bindings` 管理服务和控制器的依赖关系
- **路由管理**: 使用命名路由和页面绑定

### 2. 网络服务封装

- **统一的 Dio 封装**: 支持 GET、POST、PUT、DELETE 请求
- **拦截器支持**: 日志记录和错误处理
- **GetX 集成**: 使用 GetxService 进行生命周期管理

### 3. UI/UX 最佳实践

- **响应式状态显示**: 加载、成功、错误、空状态的优雅处理
- **Material 3 设计**: 现代化的设计语言
- **明暗主题**: 动态主题切换
- **用户反馈**: Snackbar 和 Dialog 提示

### 4. 国际化支持

- **多语言切换**: 支持中英文一键切换
- **本地化存储**: 用户语言偏好持久化
- **GetX 集成**: 完整的国际化生态支持
- **响应式切换**: 实时语言更新无需重启

### 5. 代码质量保证

- **Freezed 数据模型**: 不可变数据结构
- **代码生成**: 自动生成 JSON 序列化代码
- **Linting**: 严格的代码规范检查

## 🎯 核心示例 - Home 功能

### Controller (业务逻辑)
```dart
class HomeController extends GetxController with StateMixin<WelcomeMessage> {
  final ApiService _apiService = Get.find<ApiService>();
  
  void loadWelcomeMessage() async {
    try {
      change(null, status: RxStatus.loading());
      final data = await _apiService.getWelcomeMessage();
      change(data, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }
}
```

### View (UI 界面)
```dart
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.obx(
        (data) => _buildSuccessContent(data!),
        onLoading: _buildLoadingContent(),
        onError: (error) => _buildErrorContent(error!),
      ),
    );
  }
}
```

### Binding (依赖注入)
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
```

## 🛠️ 开发指南

### 安装依赖
```bash
flutter pub get
```

### 代码生成
```bash
flutter packages pub run build_runner build
```

### 运行应用
```bash
# Web
flutter run -d chrome

# iOS 模拟器
flutter run -d ios

# Android
flutter run -d android
```

### 添加新功能

1. **创建功能目录**:
   ```
   features/new_feature/
   ├── controllers/
   ├── views/
   └── bindings/
   ```

2. **定义数据模型** (如果需要):
   ```dart
   @freezed
   class NewModel with _$NewModel {
     const factory NewModel({required String data}) = _NewModel;
     factory NewModel.fromJson(Map<String, dynamic> json) => _$NewModelFromJson(json);
   }
   ```

3. **创建 Controller**:
   ```dart
   class NewController extends GetxController with StateMixin<NewModel> {
     // 业务逻辑
   }
   ```

4. **创建 View**:
   ```dart
   class NewView extends GetView<NewController> {
     // UI 界面
   }
   ```

5. **配置 Binding**:
   ```dart
   class NewBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<NewController>(() => NewController());
     }
   }
   ```

6. **更新路由**:
   ```dart
   // app_routes.dart
   static const String newFeature = '/new-feature';
   
   // app_pages.dart
   GetPage(
     name: AppRoutes.newFeature,
     page: () => const NewView(),
     binding: NewBinding(),
   ),
   ```

## 📚 主要依赖

```yaml
dependencies:
  get: ^4.6.6                 # GetX 状态管理、DI、路由
  dio: ^5.4.0                 # 网络请求
  freezed_annotation: ^2.4.1  # 数据模型注解
  json_annotation: ^4.8.1     # JSON 序列化注解
  get_storage: ^2.1.1         # 本地存储
  flutter_localizations:      # 国际化支持
    sdk: flutter
  intl: any                   # 国际化工具

dev_dependencies:
  build_runner: ^2.4.7        # 代码生成
  freezed: ^2.4.6             # 数据模型生成
  json_serializable: ^6.7.1   # JSON 序列化生成
  flutter_lints: ^5.0.0       # 代码规范
```

## 🎨 设计特色

- **现代化 UI**: Material 3 设计语言
- **响应式设计**: 适配不同屏幕尺寸
- **优雅的状态处理**: 加载、错误、空状态的流畅切换
- **主题系统**: 完整的明暗主题支持
- **国际化支持**: 中英文无缝切换，本地化存储
- **交互反馈**: 丰富的用户反馈机制

## 🔧 AI 治理

项目包含 `.cursor/rules` 文件，固化了 GetX 架构原则和编码规范，确保：

- 强制使用 GetX 生态系统
- 遵循 Feature-First 目录结构
- 统一的代码风格和最佳实践
- 完整的错误处理和状态管理模式
- 国际化文本的规范化使用

## 📝 许可证

本项目仅用于学习和演示目的。

---

**Flutter101** - 让 GetX 架构更简单！ 🚀