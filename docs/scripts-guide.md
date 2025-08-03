# 🚀 Flutter101 脚本工具指南

Flutter101 项目提供了一套完整的 Dart 脚本工具，帮助开发者快速开发和维护项目。

## 📋 脚本概览

| 脚本 | 功能 | 文件 |
|------|------|------|
| 🏗️ 项目初始化 | 修改项目名、包名、应用名 | `project_init.dart` |
| 📄 页面生成器 | 生成 GetX 页面（Controller、View、Binding） | `generate_page.dart` |
| 📦 模型生成器 | 生成 Freezed 数据模型 | `generate_model.dart` |
| ⚙️ 服务生成器 | 生成服务类 | `generate_service.dart` |
| 🌐 翻译管理器 | 管理多语言翻译 | `translation_manager.dart` |
| 🔧 构建工具 | 项目构建和维护 | `build_tools.dart` |
| 🎯 脚本管理器 | 统一管理所有脚本 | `script_manager.dart` |

## 🚀 快速开始

### 1. 使用脚本管理器（推荐）

最简单的方式是使用脚本管理器：

```bash
dart run scripts/script_manager.dart
```

或者使用 Makefile：

```bash
make scripts
```

### 2. 直接运行脚本

```bash
# 直接运行特定脚本
dart run scripts/project_init.dart
dart run scripts/generate_page.dart user_profile
```

### 3. 使用 Makefile 快捷命令

```bash
# 查看所有可用命令
make help

# 项目初始化
make init

# 生成页面
make page name=user_profile

# 检查翻译
make trans-check
```

## 📖 详细使用指南

### 🏗️ 项目初始化脚本

用于将 Flutter101 脚手架定制为你的新项目。

#### 功能
- 修改项目名称
- 更新包名（Android 和 iOS）
- 修改应用显示名称
- 更新项目描述
- 自动更新所有相关配置文件

#### 使用方法

```bash
# 交互式配置
dart run scripts/project_init.dart

# 或使用 Makefile
make init
```

#### 执行流程
1. 输入新的项目信息
2. 确认修改内容
3. 自动更新所有配置文件
4. 提示后续操作

#### 示例
```bash
$ dart run scripts/project_init.dart

🚀 Flutter101 项目初始化脚本
=====================================

📋 请输入项目信息
─────────────────────

? 项目名称 (例: my_awesome_app) [my_new_project]: awesome_shop
? 包名 (例: com.company.app) [com.example.awesome_shop]: com.mycompany.awesomeshop  
? 应用显示名称 [Awesome Shop]: Awesome Shop
? 项目描述 [A new Flutter project built with GetX architecture.]: 一个基于GetX的购物应用

📋 确认修改信息
─────────────────
项目名称: awesome_shop
包名: com.mycompany.awesomeshop
应用名称: Awesome Shop
描述: 一个基于GetX的购物应用

? 确认执行以上修改？ (y/N): y

🔧 更新 pubspec.yaml
🔧 更新应用名称  
🔧 更新 Android 包名
🔧 更新 iOS Bundle ID
🔧 更新 main.dart
🔧 更新 README.md

✅ 项目初始化完成！

请运行以下命令完成设置：
  flutter clean
  flutter pub get
  flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 📄 页面生成器

快速生成符合 GetX 架构的完整页面。

#### 功能
- 生成 GetxController
- 生成 GetView
- 生成 Bindings
- 自动配置路由
- 可选添加翻译支持

#### 使用方法

```bash
# 交互式生成
dart run scripts/generate_page.dart

# 快速生成（使用默认配置）
dart run scripts/generate_page.dart user_profile

# 使用 Makefile
make page name=user_profile
```

#### 生成的文件结构
```
lib/features/user/
├── controllers/
│   └── user_profile_controller.dart
├── views/
│   └── user_profile_view.dart
└── bindings/
    └── user_profile_binding.dart
```

#### 示例
```bash
$ dart run scripts/generate_page.dart

📄 GetX 页面生成器
═══════════════════════

📋 页面信息配置
─────────────────

? 页面名称 (例: user_profile, product_detail): product_detail
? 页面显示名称 [Product Detail]: 产品详情
? 是否添加翻译支持？ (y/N): y
? 是否包含 AppBar？ (y/N): y
? 是否包含 FloatingActionButton？ (y/N): n

选择需要注入的服务 (可多选):
  1. NetworkService
  2. LocalizationService  
  3. ApiService

? 请选择: 2,3

📋 确认生成信息
─────────────────
页面名称: product_detail
功能模块: product
类名: ProductDetailController
路由路径: /product_detail
显示名称: 产品详情
翻译支持: 是
包含 AppBar: 是
包含 FAB: 否
依赖服务: LocalizationService, ApiService

? 确认生成页面？ (y/N): y

🔧 生成 Controller
🔧 生成 View
🔧 生成 Binding
🔧 更新路由配置
🔧 添加翻译文本

✅ 页面生成完成！

生成的文件：
  - lib/features/product/controllers/product_detail_controller.dart
  - lib/features/product/views/product_detail_view.dart
  - lib/features/product/bindings/product_detail_binding.dart

路由已添加到：
  - lib/app/routes/app_routes.dart
  - lib/app/routes/app_pages.dart

使用方法：
  Get.toNamed(AppRoutes.productDetail);
```

### 📦 模型生成器

生成 Freezed 数据模型，支持 JSON 序列化。

#### 功能
- 生成 Freezed 模型
- 支持 JSON 序列化/反序列化
- 自动生成 copyWith 方法
- 支持默认值和可空字段

#### 使用方法

```bash
# 交互式生成
dart run scripts/generate_model.dart

# 快速生成
dart run scripts/generate_model.dart user

# 使用 Makefile
make model name=user
```

#### 示例

```bash
$ dart run scripts/generate_model.dart

📦 Freezed 模型生成器
═══════════════════════

📋 模型信息配置
─────────────────

? 模型名称 (例: user, product, order_item): user
? 模型描述 [User data model]: 用户数据模型

📋 生成选项
─────────────

? 是否生成 fromJson 方法？ (y/N): y
? 是否生成 toJson 方法？ (y/N): y  
? 是否生成 copyWith 方法？ (y/N): y
? 是否生成相等性比较？ (y/N): y

📋 添加模型字段
─────────────────

--- 字段 1 ---
? 字段名称 (留空结束): id
? 选择字段类型: 1. String
? 是否可为空？ (y/N): n
? 是否必需？ (y/N): y

--- 字段 2 ---  
? 字段名称 (留空结束): name
? 选择字段类型: 1. String
? 是否可为空？ (y/N): n
? 是否必需？ (y/N): y

--- 字段 3 ---
? 字段名称 (留空结束): email  
? 选择字段类型: 1. String
? 是否可为空？ (y/N): n
? 是否必需？ (y/N): y

--- 字段 4 ---
? 字段名称 (留空结束): avatar
? 选择字段类型: 1. String
? 是否可为空？ (y/N): y
? 默认值 (留空表示无默认值): 

--- 字段 5 ---
? 字段名称 (留空结束): 

📋 确认生成信息
─────────────────
模型名称: user
类名: User
文件名: user.dart
描述: 用户数据模型
字段数量: 4

字段列表:
  - id: String (必需)
  - name: String (必需)  
  - email: String (必需)
  - avatar: String?

生成选项:
  fromJson: 是
  toJson: 是
  copyWith: 是
  相等性比较: 是

? 确认生成模型？ (y/N): y

🔧 生成模型文件

✅ 模型生成完成！

生成的文件：
  - lib/app/data/models/user.dart

请运行以下命令生成代码：
  flutter packages pub run build_runner build
```

### ⚙️ 服务生成器

生成服务类，支持不同类型的服务。

#### 功能
- 生成 API 服务
- 生成核心服务
- 生成功能服务
- 自动配置依赖注入

#### 使用方法

```bash
# 交互式生成
dart run scripts/generate_service.dart

# 快速生成
dart run scripts/generate_service.dart user_api

# 使用 Makefile
make service name=user_api
```

### 🌐 翻译管理器

管理项目的多语言翻译。

#### 功能
- 检查翻译完整性
- 添加新翻译
- 查找未使用的翻译
- 导入/导出翻译
- 显示翻译统计

#### 使用方法

```bash
# 交互式管理
dart run scripts/translation_manager.dart

# 检查翻译完整性
dart run scripts/translation_manager.dart check

# 添加翻译
dart run scripts/translation_manager.dart add welcome_text "Welcome" "欢迎"

# 使用 Makefile
make trans-check
make trans-add key=hello en='Hello' zh='你好'
```

#### 命令参考

```bash
# 检查翻译完整性
dart run scripts/translation_manager.dart check

# 添加新翻译
dart run scripts/translation_manager.dart add <key> <en_text> <zh_text>

# 导出翻译到 JSON
dart run scripts/translation_manager.dart export

# 从 JSON 导入翻译
dart run scripts/translation_manager.dart import <json_file>

# 显示翻译统计
dart run scripts/translation_manager.dart stats
```

### 🔧 构建工具

项目构建和维护工具。

#### 功能
- 清理项目
- 获取依赖
- 生成代码
- 分析代码
- 构建应用
- 运行应用
- 检查依赖

#### 使用方法

```bash
# 交互式工具
dart run scripts/build_tools.dart

# 特定命令
dart run scripts/build_tools.dart clean
dart run scripts/build_tools.dart run web

# 使用 Makefile
make clean
make run-web
```

#### 命令参考

```bash
# 项目维护
dart run scripts/build_tools.dart clean      # 清理项目
dart run scripts/build_tools.dart get        # 获取依赖
dart run scripts/build_tools.dart generate   # 生成代码
dart run scripts/build_tools.dart analyze    # 分析代码

# 构建和运行
dart run scripts/build_tools.dart build      # 构建应用
dart run scripts/build_tools.dart run web    # 运行 Web
dart run scripts/build_tools.dart run android # 运行 Android

# 依赖管理
dart run scripts/build_tools.dart deps       # 检查依赖
dart run scripts/build_tools.dart rebuild    # 完整重建
```

## 🎯 使用场景和工作流

### 新项目设置

```bash
# 1. 初始化项目
make init

# 2. 设置开发环境
make setup

# 3. 运行项目
make run-web
```

### 日常开发

```bash
# 1. 创建新页面
make page name=user_profile

# 2. 创建数据模型
make model name=user

# 3. 创建 API 服务
make service name=user_api

# 4. 添加翻译
make trans-add key=welcome en='Welcome' zh='欢迎'

# 5. 生成代码
make gen
```

### 项目维护

```bash
# 检查翻译完整性
make trans-check

# 检查依赖
make deps

# 完整重建
make rebuild

# 代码分析
make analyze
```

## 💡 最佳实践

### 1. 命名规范

- **页面名称**: 使用 snake_case，如 `user_profile`、`product_detail`
- **模型名称**: 使用 snake_case，如 `user`、`order_item`
- **服务名称**: 使用 snake_case，如 `user_api`、`cache_manager`
- **翻译键**: 使用 snake_case，如 `welcome_message`、`error_network`

### 2. 项目结构

生成的代码严格遵循 Feature-First 架构：

```
lib/
├── app/
│   ├── core/services/     # 核心服务
│   ├── data/
│   │   ├── models/        # 数据模型
│   │   └── services/      # API 服务
│   └── localization/      # 翻译文件
└── features/
    └── feature_name/
        ├── controllers/   # 控制器
        ├── views/         # 视图
        └── bindings/      # 依赖绑定
```

### 3. 代码生成工作流

```bash
# 每次修改模型后运行
flutter packages pub run build_runner build

# 或使用脚本
make gen
```

### 4. 翻译管理

- 添加新功能时同时添加翻译
- 定期检查翻译完整性
- 使用统一的翻译键命名规范

### 5. 版本控制

建议将以下文件添加到 `.gitignore`：

```gitignore
# 生成的文件
**/*.g.dart
**/*.freezed.dart

# 构建产物
build/
.dart_tool/
```

## 🔧 自定义和扩展

### 添加新脚本

1. 在 `scripts/` 目录下创建新的 Dart 脚本
2. 在 `script_manager.dart` 中添加脚本信息
3. 在 `Makefile` 中添加快捷命令

### 自定义模板

脚本中的代码模板可以根据项目需求进行定制：

- 修改 `generate_page.dart` 中的页面模板
- 修改 `generate_model.dart` 中的模型模板
- 修改 `generate_service.dart` 中的服务模板

### 集成 CI/CD

```yaml
# GitHub Actions 示例
- name: Setup project
  run: make setup

- name: Run analysis
  run: make analyze

- name: Build app
  run: make build
```

## 🆘 故障排除

### 常见问题

1. **脚本权限问题**
   ```bash
   chmod +x scripts/*.dart
   ```

2. **依赖冲突**
   ```bash
   make clean
   make get
   ```

3. **代码生成失败**
   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

### 获取帮助

- 查看脚本帮助: `dart run scripts/script_manager.dart`
- 查看 Makefile 帮助: `make help`
- 查看项目文档: `docs/` 目录

---

通过这套完整的脚本工具，你可以大大提高 Flutter 项目的开发效率，保持代码的一致性和质量。所有脚本都遵循 GetX 架构原则，确保生成的代码符合项目规范。