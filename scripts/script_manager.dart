#!/usr/bin/env dart

import 'dart:io';
import 'utils/console_utils.dart';

/// 脚本管理器
/// 统一管理和运行所有项目脚本
void main(List<String> args) async {
  print(ConsoleUtils.banner('🚀 Flutter101 脚本管理器'));

  if (args.isEmpty) {
    await _showMainMenu();
  } else {
    await _runScript(args[0], args.skip(1).toList());
  }
}

class ScriptInfo {
  final String name;
  final String file;
  final String description;
  final String icon;
  final List<String> examples;

  ScriptInfo({
    required this.name,
    required this.file,
    required this.description,
    required this.icon,
    this.examples = const [],
  });
}

final availableScripts = [
  ScriptInfo(
    name: '项目初始化',
    file: 'project_init.dart',
    description: '修改项目名、包名、应用名等信息',
    icon: '🏗️',
    examples: ['dart run scripts/project_init.dart'],
  ),
  ScriptInfo(
    name: '页面生成器',
    file: 'generate_page.dart',
    description: '快速生成新的功能页面（Controller、View、Binding、路由）',
    icon: '📄',
    examples: [
      'dart run scripts/generate_page.dart',
      'dart run scripts/generate_page.dart user_profile',
      'dart run scripts/generate_page.dart product_detail',
    ],
  ),
  ScriptInfo(
    name: '模型生成器',
    file: 'generate_model.dart',
    description: '生成 Freezed 数据模型',
    icon: '📦',
    examples: [
      'dart run scripts/generate_model.dart',
      'dart run scripts/generate_model.dart user',
      'dart run scripts/generate_model.dart product',
    ],
  ),
  ScriptInfo(
    name: '服务生成器',
    file: 'generate_service.dart',
    description: '生成新的服务类',
    icon: '⚙️',
    examples: [
      'dart run scripts/generate_service.dart',
      'dart run scripts/generate_service.dart user_api',
      'dart run scripts/generate_service.dart cache_manager',
    ],
  ),
  ScriptInfo(
    name: '翻译管理器',
    file: 'translation_manager.dart',
    description: '管理多语言翻译（检查完整性、添加翻译、导入导出）',
    icon: '🌐',
    examples: [
      'dart run scripts/translation_manager.dart',
      'dart run scripts/translation_manager.dart check',
      'dart run scripts/translation_manager.dart add welcome_text "Welcome" "欢迎"',
    ],
  ),
  ScriptInfo(
    name: '构建工具',
    file: 'build_tools.dart',
    description: '项目构建和维护工具',
    icon: '🔧',
    examples: [
      'dart run scripts/build_tools.dart',
      'dart run scripts/build_tools.dart clean',
      'dart run scripts/build_tools.dart run web',
    ],
  ),
];

Future<void> _showMainMenu() async {
  while (true) {
    print(ConsoleUtils.section('可用脚本'));

    final options = availableScripts
        .map(
          (script) => '${script.icon} ${script.name} - ${script.description}',
        )
        .toList();
    options.add('📖 查看使用文档');
    options.add('❌ 退出');

    final choice = ConsoleUtils.menu('选择要运行的脚本', options);

    if (choice == options.length - 1) {
      print(ConsoleUtils.info('再见！'));
      return;
    } else if (choice == options.length - 2) {
      _showDocumentation();
      print('\n按 Enter 继续...');
      stdin.readLineSync();
      continue;
    }

    try {
      final script = availableScripts[choice];
      await _runScript(script.file, []);

      print('\n按 Enter 继续...');
      stdin.readLineSync();
    } catch (e) {
      print(ConsoleUtils.error('脚本执行失败: $e'));
      print('\n按 Enter 继续...');
      stdin.readLineSync();
    }
  }
}

Future<void> _runScript(String scriptFile, List<String> args) async {
  final scriptPath = 'scripts/$scriptFile';

  if (!File(scriptPath).existsSync()) {
    throw Exception('脚本文件不存在: $scriptPath');
  }

  print(ConsoleUtils.info('运行脚本: $scriptPath'));

  final process = await Process.start('dart', ['run', scriptPath, ...args]);

  // 转发输入输出
  stdin.pipe(process.stdin);
  process.stdout.pipe(stdout);
  process.stderr.pipe(stderr);

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception('脚本执行失败，退出码: $exitCode');
  }
}

void _showDocumentation() {
  print(ConsoleUtils.section('📖 脚本使用文档'));

  for (final script in availableScripts) {
    print('\n${script.icon} ${ConsoleUtils.info(script.name)}');
    print('   ${script.description}');

    if (script.examples.isNotEmpty) {
      print('   示例用法:');
      for (final example in script.examples) {
        print('     $example');
      }
    }
  }

  print('\n${ConsoleUtils.section('快速开始指南')}');

  print('''
🚀 新项目设置流程:
1. 运行项目初始化脚本修改项目信息
2. 运行构建工具获取依赖和生成代码
3. 使用页面生成器创建新功能

📝 开发工作流:
1. 使用模型生成器创建数据模型
2. 使用服务生成器创建API服务
3. 使用页面生成器创建功能页面
4. 使用翻译管理器添加多语言支持

🔧 维护和构建:
1. 使用构建工具清理和重建项目
2. 使用翻译管理器检查翻译完整性
3. 定期运行代码分析和依赖检查

💡 提示:
- 所有脚本都支持交互式输入和命令行参数
- 生成的代码遵循项目的 GetX 架构规范
- 脚本会自动更新相关配置文件
''');
}
