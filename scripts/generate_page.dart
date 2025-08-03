#!/usr/bin/env dart

import 'dart:io';
import 'utils/file_utils.dart';
import 'utils/console_utils.dart';

/// 页面生成脚本
/// 快速生成新的 feature 页面，包括 controller、view、binding 和路由
void main(List<String> args) async {
  print(ConsoleUtils.banner('📄 GetX 页面生成器'));

  try {
    // 从命令行参数或交互式输入获取页面信息
    final pageInfo = args.isNotEmpty
        ? _parseArgsToPageInfo(args)
        : await _getPageInfoInteractive();

    // 确认生成信息
    if (!await _confirmGeneration(pageInfo)) {
      print(ConsoleUtils.warning('操作已取消'));
      return;
    }

    print(ConsoleUtils.info('开始生成页面...'));

    // 生成文件
    await _generateController(pageInfo);
    await _generateView(pageInfo);
    await _generateBinding(pageInfo);
    await _updateRoutes(pageInfo);

    // 可选：添加翻译
    if (pageInfo.addTranslations) {
      await _addTranslations(pageInfo);
    }

    print(ConsoleUtils.success('✅ 页面生成完成！'));
    print(ConsoleUtils.info('生成的文件：'));
    print(
      '  - lib/features/${pageInfo.featureName}/controllers/${pageInfo.fileName}_controller.dart',
    );
    print(
      '  - lib/features/${pageInfo.featureName}/views/${pageInfo.fileName}_view.dart',
    );
    print(
      '  - lib/features/${pageInfo.featureName}/bindings/${pageInfo.fileName}_binding.dart',
    );
    print('');
    print(ConsoleUtils.info('路由已添加到：'));
    print('  - lib/app/routes/app_routes.dart');
    print('  - lib/app/routes/app_pages.dart');
    print('');
    print(ConsoleUtils.info('使用方法：'));
    print('  Get.toNamed(AppRoutes.${pageInfo.variableName});');
  } catch (e) {
    print(ConsoleUtils.error('❌ 生成失败: $e'));
    exit(1);
  }
}

class PageInfo {
  final String pageName;
  final String featureName;
  final String fileName;
  final String className;
  final String variableName;
  final String routePath;
  final String displayName;
  final bool addTranslations;
  final bool hasAppBar;
  final bool hasFloatingButton;
  final List<String> dependencies;

  PageInfo({
    required this.pageName,
    required this.featureName,
    required this.fileName,
    required this.className,
    required this.variableName,
    required this.routePath,
    required this.displayName,
    this.addTranslations = true,
    this.hasAppBar = true,
    this.hasFloatingButton = false,
    this.dependencies = const [],
  });
}

PageInfo _parseArgsToPageInfo(List<String> args) {
  if (args.isEmpty) {
    throw Exception('使用方法: dart run scripts/generate_page.dart <page_name>');
  }

  final pageName = args[0];
  return _createPageInfo(pageName);
}

Future<PageInfo> _getPageInfoInteractive() async {
  print(ConsoleUtils.section('页面信息配置'));

  final pageName = ConsoleUtils.prompt(
    '页面名称 (例: user_profile, product_detail)',
    validator: (value) => _validatePageName(value),
  );

  final displayName = ConsoleUtils.prompt(
    '页面显示名称',
    defaultValue: _formatDisplayName(pageName),
  );

  final addTranslations = ConsoleUtils.confirm('是否添加翻译支持？');
  final hasAppBar = ConsoleUtils.confirm('是否包含 AppBar？');
  final hasFloatingButton = ConsoleUtils.confirm('是否包含 FloatingActionButton？');

  // 选择依赖服务
  final dependencies = await _selectDependencies();

  final pageInfo = _createPageInfo(pageName);

  return PageInfo(
    pageName: pageInfo.pageName,
    featureName: pageInfo.featureName,
    fileName: pageInfo.fileName,
    className: pageInfo.className,
    variableName: pageInfo.variableName,
    routePath: pageInfo.routePath,
    displayName: displayName,
    addTranslations: addTranslations,
    hasAppBar: hasAppBar,
    hasFloatingButton: hasFloatingButton,
    dependencies: dependencies,
  );
}

PageInfo _createPageInfo(String pageName) {
  final fileName = FileUtils.toFileName(pageName);
  final className = FileUtils.toClassName(pageName);
  final variableName = FileUtils.toVariableName(pageName);
  final featureName = fileName.split('_').first;

  return PageInfo(
    pageName: pageName,
    featureName: featureName,
    fileName: fileName,
    className: className,
    variableName: variableName,
    routePath: '/$fileName',
    displayName: _formatDisplayName(pageName),
  );
}

String? _validatePageName(String value) {
  if (value.isEmpty) return '页面名称不能为空';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    return '页面名称必须以小写字母开头，只能包含小写字母、数字和下划线';
  }
  return null;
}

String _formatDisplayName(String pageName) {
  return pageName
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

Future<List<String>> _selectDependencies() async {
  final availableServices = [
    'NetworkService',
    'LocalizationService',
    'ApiService',
  ];

  print('\n选择需要注入的服务 (可多选):');
  final indices = ConsoleUtils.multiSelect('依赖服务', availableServices);

  return indices.map((i) => availableServices[i]).toList();
}

Future<bool> _confirmGeneration(PageInfo info) async {
  print(ConsoleUtils.section('确认生成信息'));
  print('页面名称: ${info.pageName}');
  print('功能模块: ${info.featureName}');
  print('类名: ${info.className}');
  print('路由路径: ${info.routePath}');
  print('显示名称: ${info.displayName}');
  print('翻译支持: ${info.addTranslations ? '是' : '否'}');
  print('包含 AppBar: ${info.hasAppBar ? '是' : '否'}');
  print('包含 FAB: ${info.hasFloatingButton ? '是' : '否'}');
  if (info.dependencies.isNotEmpty) {
    print('依赖服务: ${info.dependencies.join(', ')}');
  }
  print('');

  return ConsoleUtils.confirm('确认生成页面？');
}

Future<void> _generateController(PageInfo info) async {
  print(ConsoleUtils.step('生成 Controller'));

  final dirPath = 'lib/features/${info.featureName}/controllers';
  await FileUtils.ensureDirectory(dirPath);

  final content = _generateControllerContent(info);
  final filePath = '$dirPath/${info.fileName}_controller.dart';

  await File(filePath).writeAsString(content);
}

String _generateControllerContent(PageInfo info) {
  final imports = <String>["import 'package:get/get.dart';"];

  if (info.dependencies.contains('LocalizationService')) {
    imports.add(
      "import '../../../app/core/services/localization_service.dart';",
    );
  }
  if (info.dependencies.contains('ApiService')) {
    imports.add("import '../../../app/data/services/api_service.dart';");
  }
  if (info.dependencies.contains('NetworkService')) {
    imports.add("import '../../../app/core/services/network_service.dart';");
  }

  final dependencies = info.dependencies
      .map(
        (dep) => '  final ${dep} _${dep.toLowerCase()} = Get.find<${dep}>();',
      )
      .join('\n');

  return '''${imports.join('\n')}

/// ${info.displayName} 控制器
class ${info.className}Controller extends GetxController {
${dependencies.isNotEmpty ? '$dependencies\n' : ''}
  // 响应式变量
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }
  
  @override
  void onReady() {
    super.onReady();
    // 页面准备完成后的操作
  }
  
  @override
  void onClose() {
    super.onClose();
    // 清理资源
  }
  
  /// 初始化数据
  void _initializeData() async {
    try {
      _isLoading.value = true;
      
      // TODO: 添加初始化逻辑
      
    } catch (e) {
      Get.log('${info.className}Controller 初始化失败: \$e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 刷新数据
  void refreshData() {
    _initializeData();
  }
  
  // TODO: 添加其他业务方法
}
''';
}

Future<void> _generateView(PageInfo info) async {
  print(ConsoleUtils.step('生成 View'));

  final dirPath = 'lib/features/${info.featureName}/views';
  await FileUtils.ensureDirectory(dirPath);

  final content = _generateViewContent(info);
  final filePath = '$dirPath/${info.fileName}_view.dart';

  await File(filePath).writeAsString(content);
}

String _generateViewContent(PageInfo info) {
  final imports = <String>[
    "import 'package:flutter/material.dart';",
    "import 'package:get/get.dart';",
    "import '../controllers/${info.fileName}_controller.dart';",
  ];

  final appBarSection = info.hasAppBar
      ? '''
      appBar: AppBar(
        title: Text(info.addTranslations ? '${info.variableName}_title' : info.displayName),
      ),'''
      : '';

  final fabSection = info.hasFloatingButton
      ? '''
      floatingActionButton: FloatingActionButton(
        onPressed: controller.refreshData,
        child: const Icon(Icons.refresh),
      ),'''
      : '';

  return '''${imports.join('\n')}

/// ${info.displayName} 页面
class ${info.className}View extends GetView<${info.className}Controller> {
  const ${info.className}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold($appBarSection
      body: Obx(
        () => controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),$fabSection
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          Text(
            info.addTranslations ? '${info.variableName}_welcome' : '欢迎来到${info.displayName}',
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 内容区域
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flutter_dash,
                    size: 64,
                    color: Get.theme.primaryColor,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    info.addTranslations ? '${info.variableName}_description' : '这是${info.displayName}页面',
                    style: Get.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: controller.refreshData,
                    child: Text(info.addTranslations ? 'refresh' : '刷新'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';
}

Future<void> _generateBinding(PageInfo info) async {
  print(ConsoleUtils.step('生成 Binding'));

  final dirPath = 'lib/features/${info.featureName}/bindings';
  await FileUtils.ensureDirectory(dirPath);

  final content = _generateBindingContent(info);
  final filePath = '$dirPath/${info.fileName}_binding.dart';

  await File(filePath).writeAsString(content);
}

String _generateBindingContent(PageInfo info) {
  final imports = <String>[
    "import 'package:get/get.dart';",
    "import '../controllers/${info.fileName}_controller.dart';",
  ];

  // 添加依赖服务的导入
  for (final dep in info.dependencies) {
    switch (dep) {
      case 'LocalizationService':
        imports.add(
          "import '../../../app/core/services/localization_service.dart';",
        );
        break;
      case 'ApiService':
        imports.add("import '../../../app/data/services/api_service.dart';");
        break;
      case 'NetworkService':
        imports.add(
          "import '../../../app/core/services/network_service.dart';",
        );
        break;
    }
  }

  final dependencyRegistrations = info.dependencies
      .map(
        (dep) =>
            '''
    // 确保 $dep 可用
    if (!Get.isRegistered<$dep>()) {
      Get.lazyPut<$dep>(() => $dep());
    }''',
      )
      .join('\n');

  return '''${imports.join('\n')}

/// ${info.displayName} 依赖绑定
class ${info.className}Binding extends Bindings {
  @override
  void dependencies() {${dependencyRegistrations.isNotEmpty ? dependencyRegistrations : ''}
    
    // 注册 Controller
    Get.lazyPut<${info.className}Controller>(() => ${info.className}Controller());
  }
}
''';
}

Future<void> _updateRoutes(PageInfo info) async {
  print(ConsoleUtils.step('更新路由配置'));

  await _updateAppRoutes(info);
  await _updateAppPages(info);
}

Future<void> _updateAppRoutes(PageInfo info) async {
  final file = File('lib/app/routes/app_routes.dart');
  if (!file.existsSync()) {
    throw Exception('app_routes.dart 文件不存在');
  }

  final routeConstant =
      "  static const String ${info.variableName} = '${info.routePath}';";

  // 检查路由是否已存在
  if (await FileUtils.fileContains(file.path, routeConstant)) {
    print(ConsoleUtils.warning('路由常量已存在，跳过添加'));
    return;
  }

  // 在最后一个 } 之前插入新路由
  final lines = await file.readAsLines();
  final lastBraceIndex = lines.lastIndexWhere((line) => line.trim() == '}');

  if (lastBraceIndex != -1) {
    lines.insert(lastBraceIndex, routeConstant);
    await file.writeAsString(lines.join('\n') + '\n');
  }
}

Future<void> _updateAppPages(PageInfo info) async {
  final file = File('lib/app/routes/app_pages.dart');
  if (!file.existsSync()) {
    throw Exception('app_pages.dart 文件不存在');
  }

  // 添加导入
  final viewImport =
      "import '../../features/${info.featureName}/views/${info.fileName}_view.dart';";
  final bindingImport =
      "import '../../features/${info.featureName}/bindings/${info.fileName}_binding.dart';";

  await FileUtils.insertInFile(
    file.path,
    "import 'app_routes.dart';",
    viewImport,
  );
  await FileUtils.insertInFile(file.path, viewImport, bindingImport);

  // 添加路由页面配置
  final pageConfig =
      '''    GetPage(
      name: AppRoutes.${info.variableName},
      page: () => const ${info.className}View(),
      binding: ${info.className}Binding(),
    ),''';

  await FileUtils.insertInFile(
    file.path,
    'static final routes = [',
    pageConfig,
  );
}

Future<void> _addTranslations(PageInfo info) async {
  print(ConsoleUtils.step('添加翻译文本'));

  final file = File('lib/app/localization/app_translations.dart');
  if (!file.existsSync()) {
    print(ConsoleUtils.warning('翻译文件不存在，跳过添加翻译'));
    return;
  }

  final translations = {
    '${info.variableName}_title': {
      'en': info.displayName,
      'zh': info.displayName, // 可以根据需要修改
    },
    '${info.variableName}_welcome': {
      'en': 'Welcome to ${info.displayName}',
      'zh': '欢迎来到${info.displayName}',
    },
    '${info.variableName}_description': {
      'en': 'This is the ${info.displayName} page',
      'zh': '这是${info.displayName}页面',
    },
  };

  String content = await file.readAsString();

  for (final entry in translations.entries) {
    final key = entry.key;
    final values = entry.value;

    // 添加英文翻译
    final enPattern = RegExp(r"'en_US':\s*\{([^}]+)\}");
    final enMatch = enPattern.firstMatch(content);
    if (enMatch != null) {
      final newEnContent =
          "${enMatch.group(1)?.trimRight()}\n          '$key': '${values['en']}',\n        ";
      content = content.replaceFirst(
        enPattern,
        "'en_US': {\n        $newEnContent}",
      );
    }

    // 添加中文翻译
    final zhPattern = RegExp(r"'zh_CN':\s*\{([^}]+)\}");
    final zhMatch = zhPattern.firstMatch(content);
    if (zhMatch != null) {
      final newZhContent =
          "${zhMatch.group(1)?.trimRight()}\n          '$key': '${values['zh']}',\n        ";
      content = content.replaceFirst(
        zhPattern,
        "'zh_CN': {\n        $newZhContent}",
      );
    }
  }

  await file.writeAsString(content);
}
