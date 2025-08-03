#!/usr/bin/env dart

import 'dart:io';
import 'utils/console_utils.dart';

/// 项目初始化脚本
/// 用于修改项目名、包名、应用名等，让用户能快速定制新项目
void main(List<String> args) async {
  print(ConsoleUtils.banner('🚀 Flutter101 项目初始化脚本'));

  try {
    // 获取用户输入
    final projectInfo = await _getProjectInfo();

    // 确认信息
    if (!await _confirmChanges(projectInfo)) {
      print(ConsoleUtils.warning('操作已取消'));
      return;
    }

    print(ConsoleUtils.info('开始初始化项目...'));

    // 执行各种修改
    await _updatePubspecYaml(projectInfo);
    await _updateAppName(projectInfo);
    await _updateAndroidPackage(projectInfo);
    await _updateIOSBundleId(projectInfo);
    await _updateMainDart(projectInfo);
    await _updateReadme(projectInfo);

    print(ConsoleUtils.success('✅ 项目初始化完成！'));
    print(ConsoleUtils.info('请运行以下命令完成设置：'));
    print('  flutter clean');
    print('  flutter pub get');
    print(
      '  flutter packages pub run build_runner build --delete-conflicting-outputs',
    );
  } catch (e) {
    print(ConsoleUtils.error('❌ 初始化失败: $e'));
    exit(1);
  }
}

class ProjectInfo {
  final String projectName;
  final String packageName;
  final String appName;
  final String description;

  ProjectInfo({
    required this.projectName,
    required this.packageName,
    required this.appName,
    required this.description,
  });
}

Future<ProjectInfo> _getProjectInfo() async {
  print(ConsoleUtils.section('请输入项目信息'));

  final projectName = ConsoleUtils.prompt(
    '项目名称 (例: my_awesome_app)',
    defaultValue: 'my_new_project',
    validator: (value) => _validateProjectName(value),
  );

  final packageName = ConsoleUtils.prompt(
    '包名 (例: com.company.app)',
    defaultValue: 'com.example.$projectName',
    validator: (value) => _validatePackageName(value),
  );

  final appName = ConsoleUtils.prompt(
    '应用显示名称',
    defaultValue: _formatAppName(projectName),
  );

  final description = ConsoleUtils.prompt(
    '项目描述',
    defaultValue: 'A new Flutter project built with GetX architecture.',
  );

  return ProjectInfo(
    projectName: projectName,
    packageName: packageName,
    appName: appName,
    description: description,
  );
}

String? _validateProjectName(String value) {
  if (value.isEmpty) return '项目名称不能为空';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    return '项目名称必须以小写字母开头，只能包含小写字母、数字和下划线';
  }
  return null;
}

String? _validatePackageName(String value) {
  if (value.isEmpty) return '包名不能为空';
  if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$').hasMatch(value)) {
    return '包名格式不正确，应类似: com.company.app';
  }
  return null;
}

String _formatAppName(String projectName) {
  return projectName
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

Future<bool> _confirmChanges(ProjectInfo info) async {
  print(ConsoleUtils.section('确认修改信息'));
  print('项目名称: ${info.projectName}');
  print('包名: ${info.packageName}');
  print('应用名称: ${info.appName}');
  print('描述: ${info.description}');
  print('');

  return ConsoleUtils.confirm('确认执行以上修改？');
}

Future<void> _updatePubspecYaml(ProjectInfo info) async {
  print(ConsoleUtils.step('更新 pubspec.yaml'));

  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    throw Exception('pubspec.yaml 文件不存在');
  }

  String content = await file.readAsString();
  content = content.replaceFirst(
    RegExp(r'^name:\s*.*$', multiLine: true),
    'name: ${info.projectName}',
  );
  content = content.replaceFirst(
    RegExp(r'^description:\s*.*$', multiLine: true),
    'description: "${info.description}"',
  );

  await file.writeAsString(content);
}

Future<void> _updateAppName(ProjectInfo info) async {
  print(ConsoleUtils.step('更新应用名称'));

  // 更新翻译文件中的应用名称
  await _updateTranslationFile(info.appName);
}

Future<void> _updateTranslationFile(String appName) async {
  final file = File('lib/app/localization/app_translations.dart');
  if (!file.existsSync()) return;

  String content = await file.readAsString();
  content = content.replaceAll(
    RegExp(r"'app_name':\s*'[^']*'"),
    "'app_name': '$appName'",
  );

  await file.writeAsString(content);
}

Future<void> _updateAndroidPackage(ProjectInfo info) async {
  print(ConsoleUtils.step('更新 Android 包名'));

  // 更新 build.gradle.kts
  await _updateAndroidBuildGradle(info.packageName);

  // 更新 AndroidManifest.xml 文件
  await _updateAndroidManifests(info.packageName);

  // 更新 MainActivity.kt
  await _updateMainActivity(info);
}

Future<void> _updateAndroidBuildGradle(String packageName) async {
  final file = File('android/app/build.gradle.kts');
  if (!file.existsSync()) return;

  String content = await file.readAsString();
  content = content.replaceFirst(
    RegExp(r'applicationId\s*=\s*"[^"]*"'),
    'applicationId = "$packageName"',
  );

  await file.writeAsString(content);
}

Future<void> _updateAndroidManifests(String packageName) async {
  final manifestFiles = [
    'android/app/src/main/AndroidManifest.xml',
    'android/app/src/debug/AndroidManifest.xml',
    'android/app/src/profile/AndroidManifest.xml',
  ];

  for (final path in manifestFiles) {
    final file = File(path);
    if (!file.existsSync()) continue;

    String content = await file.readAsString();
    content = content.replaceAll(
      RegExp(r'package="[^"]*"'),
      'package="$packageName"',
    );

    await file.writeAsString(content);
  }
}

Future<void> _updateMainActivity(ProjectInfo info) async {
  final file = File(
    'android/app/src/main/kotlin/com/example/flutter101/MainActivity.kt',
  );
  if (!file.existsSync()) return;

  final packageParts = info.packageName.split('.');
  final newPath =
      'android/app/src/main/kotlin/${packageParts.join('/')}/MainActivity.kt';

  // 创建新的目录结构
  final newDir = Directory(newPath).parent;
  if (!newDir.existsSync()) {
    await newDir.create(recursive: true);
  }

  // 更新包声明并移动文件
  String content = await file.readAsString();
  content = content.replaceFirst(
    RegExp(r'^package\s+.*$', multiLine: true),
    'package ${info.packageName}',
  );

  await File(newPath).writeAsString(content);

  // 删除旧文件
  if (file.path != newPath) {
    await file.delete();
  }
}

Future<void> _updateIOSBundleId(ProjectInfo info) async {
  print(ConsoleUtils.step('更新 iOS Bundle ID'));

  // 更新 Info.plist
  await _updateIOSInfoPlist(info.packageName);

  // 更新 project.pbxproj
  await _updateIOSProject(info.packageName);
}

Future<void> _updateIOSInfoPlist(String bundleId) async {
  final file = File('ios/Runner/Info.plist');
  if (!file.existsSync()) return;

  String content = await file.readAsString();
  content = content.replaceAll(
    RegExp(r'<key>CFBundleIdentifier</key>\s*<string>[^<]*</string>'),
    '<key>CFBundleIdentifier</key>\n\t<string>$bundleId</string>',
  );

  await file.writeAsString(content);
}

Future<void> _updateIOSProject(String bundleId) async {
  final file = File('ios/Runner.xcodeproj/project.pbxproj');
  if (!file.existsSync()) return;

  String content = await file.readAsString();
  content = content.replaceAll(
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*[^;]*;'),
    'PRODUCT_BUNDLE_IDENTIFIER = $bundleId;',
  );

  await file.writeAsString(content);
}

Future<void> _updateMainDart(ProjectInfo info) async {
  print(ConsoleUtils.step('更新 main.dart'));

  final file = File('lib/main.dart');
  if (!file.existsSync()) return;

  String content = await file.readAsString();
  content = content.replaceFirst(
    RegExp(r"title:\s*'[^']*'"),
    "title: '${info.appName}'",
  );

  await file.writeAsString(content);
}

Future<void> _updateReadme(ProjectInfo info) async {
  print(ConsoleUtils.step('更新 README.md'));

  final file = File('README.md');
  if (!file.existsSync()) return;

  String content = await file.readAsString();
  content = content.replaceFirst(
    RegExp(r'^#\s*.*$', multiLine: true),
    '# ${info.appName}',
  );
  content = content.replaceFirst(
    RegExp(r'^一个基于.*$', multiLine: true),
    '${info.description}',
  );

  await file.writeAsString(content);
}
