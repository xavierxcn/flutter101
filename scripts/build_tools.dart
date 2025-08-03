#!/usr/bin/env dart

import 'dart:io';
import 'utils/console_utils.dart';

/// 构建工具脚本
/// 提供各种构建和维护命令
void main(List<String> args) async {
  print(ConsoleUtils.banner('🔧 Flutter101 构建工具'));

  if (args.isEmpty) {
    await _showMainMenu();
  } else {
    await _handleCommand(args);
  }
}

Future<void> _showMainMenu() async {
  while (true) {
    final options = [
      '🧹 清理项目',
      '📦 获取依赖',
      '⚙️ 生成代码',
      '🔍 分析代码',
      '🚀 构建应用',
      '🌐 运行 Web',
      '📱 运行 Android',
      '🍎 运行 iOS',
      '📊 依赖检查',
      '🔄 完整重建',
      '❌ 退出',
    ];

    final choice = ConsoleUtils.menu('选择操作', options);

    try {
      switch (choice) {
        case 0:
          await _cleanProject();
          break;
        case 1:
          await _getPubDeps();
          break;
        case 2:
          await _generateCode();
          break;
        case 3:
          await _analyzeCode();
          break;
        case 4:
          await _buildApp();
          break;
        case 5:
          await _runWeb();
          break;
        case 6:
          await _runAndroid();
          break;
        case 7:
          await _runIOS();
          break;
        case 8:
          await _checkDependencies();
          break;
        case 9:
          await _fullRebuild();
          break;
        case 10:
          print(ConsoleUtils.info('再见！'));
          return;
      }

      print('\n按 Enter 继续...');
      stdin.readLineSync();
    } catch (e) {
      print(ConsoleUtils.error('操作失败: $e'));
      print('\n按 Enter 继续...');
      stdin.readLineSync();
    }
  }
}

Future<void> _handleCommand(List<String> args) async {
  switch (args[0]) {
    case 'clean':
      await _cleanProject();
      break;
    case 'get':
      await _getPubDeps();
      break;
    case 'generate':
    case 'gen':
      await _generateCode();
      break;
    case 'analyze':
      await _analyzeCode();
      break;
    case 'build':
      final platform = args.length > 1 ? args[1] : null;
      await _buildApp(platform: platform);
      break;
    case 'run':
      final platform = args.length > 1 ? args[1] : 'web';
      await _runApp(platform);
      break;
    case 'deps':
      await _checkDependencies();
      break;
    case 'rebuild':
      await _fullRebuild();
      break;
    default:
      print('未知命令: ${args[0]}');
      print('可用命令: clean, get, generate, analyze, build, run, deps, rebuild');
      exit(1);
  }
}

Future<void> _cleanProject() async {
  print(ConsoleUtils.section('清理项目'));

  final commands = ['flutter clean', 'dart run build_runner clean'];

  for (final cmd in commands) {
    print(ConsoleUtils.step('执行: $cmd'));
    final result = await Process.run('flutter', ['clean']);
    if (result.exitCode != 0) {
      throw Exception('命令执行失败: ${result.stderr}');
    }
  }

  // 清理额外的缓存目录
  final cacheDirs = [
    '.dart_tool',
    'build',
    '.flutter-plugins',
    '.flutter-plugins-dependencies',
  ];

  for (final dir in cacheDirs) {
    final directory = Directory(dir);
    if (directory.existsSync()) {
      print(ConsoleUtils.step('删除: $dir'));
      await directory.delete(recursive: true);
    }
  }

  print(ConsoleUtils.success('✅ 项目清理完成'));
}

Future<void> _getPubDeps() async {
  print(ConsoleUtils.section('获取依赖'));

  print(ConsoleUtils.step('执行: flutter pub get'));
  final result = await Process.run('flutter', ['pub', 'get']);

  if (result.exitCode != 0) {
    throw Exception('获取依赖失败: ${result.stderr}');
  }

  print(result.stdout);
  print(ConsoleUtils.success('✅ 依赖获取完成'));
}

Future<void> _generateCode() async {
  print(ConsoleUtils.section('生成代码'));

  print(ConsoleUtils.step('执行: flutter packages pub run build_runner build'));
  final process = await Process.start('flutter', [
    'packages',
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);

  // 实时显示输出
  process.stdout.listen((data) {
    stdout.add(data);
  });

  process.stderr.listen((data) {
    stderr.add(data);
  });

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception('代码生成失败');
  }

  print(ConsoleUtils.success('✅ 代码生成完成'));
}

Future<void> _analyzeCode() async {
  print(ConsoleUtils.section('分析代码'));

  print(ConsoleUtils.step('执行: flutter analyze'));
  final result = await Process.run('flutter', ['analyze']);

  print(result.stdout);

  if (result.exitCode != 0) {
    print(ConsoleUtils.warning('代码分析发现问题'));
    print(result.stderr);
  } else {
    print(ConsoleUtils.success('✅ 代码分析通过'));
  }
}

Future<void> _buildApp({String? platform}) async {
  print(ConsoleUtils.section('构建应用'));

  if (platform == null) {
    final platforms = ['web', 'android', 'ios', 'windows', 'macos', 'linux'];
    final choice = ConsoleUtils.menu('选择构建平台', platforms);
    platform = platforms[choice];
  }

  print(ConsoleUtils.step('构建 $platform 应用'));

  final args = ['build', platform];
  if (platform == 'android') {
    args.addAll(['--release']);
  } else if (platform == 'web') {
    args.addAll(['--release']);
  }

  final process = await Process.start('flutter', args);

  // 实时显示输出
  process.stdout.listen((data) {
    stdout.add(data);
  });

  process.stderr.listen((data) {
    stderr.add(data);
  });

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception('构建失败');
  }

  print(ConsoleUtils.success('✅ $platform 应用构建完成'));
}

Future<void> _runApp(String platform) async {
  switch (platform.toLowerCase()) {
    case 'web':
      await _runWeb();
      break;
    case 'android':
      await _runAndroid();
      break;
    case 'ios':
      await _runIOS();
      break;
    default:
      throw Exception('不支持的平台: $platform');
  }
}

Future<void> _runWeb() async {
  print(ConsoleUtils.section('运行 Web 应用'));

  print(ConsoleUtils.step('启动: flutter run -d chrome'));

  final process = await Process.start('flutter', ['run', '-d', 'chrome']);

  // 实时显示输出
  process.stdout.listen((data) {
    stdout.add(data);
  });

  process.stderr.listen((data) {
    stderr.add(data);
  });

  print(ConsoleUtils.info('Web 应用正在运行... 按 Ctrl+C 停止'));

  // 等待用户中断
  ProcessSignal.sigint.watch().listen((_) {
    process.kill();
    print(ConsoleUtils.info('\nWeb 应用已停止'));
    exit(0);
  });

  await process.exitCode;
}

Future<void> _runAndroid() async {
  print(ConsoleUtils.section('运行 Android 应用'));

  // 检查 Android 设备
  final devicesResult = await Process.run('flutter', ['devices']);
  if (!devicesResult.stdout.toString().contains('android')) {
    throw Exception('未找到 Android 设备或模拟器');
  }

  print(ConsoleUtils.step('启动: flutter run -d android'));

  final process = await Process.start('flutter', ['run', '-d', 'android']);

  // 实时显示输出
  process.stdout.listen((data) {
    stdout.add(data);
  });

  process.stderr.listen((data) {
    stderr.add(data);
  });

  await process.exitCode;
}

Future<void> _runIOS() async {
  print(ConsoleUtils.section('运行 iOS 应用'));

  // 检查是否在 macOS 上
  if (!Platform.isMacOS) {
    throw Exception('iOS 应用只能在 macOS 上运行');
  }

  // 检查 iOS 设备
  final devicesResult = await Process.run('flutter', ['devices']);
  if (!devicesResult.stdout.toString().contains('ios')) {
    throw Exception('未找到 iOS 设备或模拟器');
  }

  print(ConsoleUtils.step('启动: flutter run -d ios'));

  final process = await Process.start('flutter', ['run', '-d', 'ios']);

  // 实时显示输出
  process.stdout.listen((data) {
    stdout.add(data);
  });

  process.stderr.listen((data) {
    stderr.add(data);
  });

  await process.exitCode;
}

Future<void> _checkDependencies() async {
  print(ConsoleUtils.section('检查依赖'));

  // 检查过期的依赖
  print(ConsoleUtils.step('检查过期依赖'));
  final outdatedResult = await Process.run('flutter', ['pub', 'outdated']);
  print(outdatedResult.stdout);

  // 检查依赖树
  print(ConsoleUtils.step('检查依赖树'));
  final depsResult = await Process.run('flutter', ['pub', 'deps']);
  print(depsResult.stdout);

  // 检查 Flutter doctor
  print(ConsoleUtils.step('检查 Flutter 环境'));
  final doctorResult = await Process.run('flutter', ['doctor']);
  print(doctorResult.stdout);

  print(ConsoleUtils.success('✅ 依赖检查完成'));
}

Future<void> _fullRebuild() async {
  print(ConsoleUtils.section('完整重建'));

  final steps = ['清理项目', '获取依赖', '生成代码', '分析代码'];

  for (int i = 0; i < steps.length; i++) {
    ConsoleUtils.progress(steps[i], i + 1, steps.length);

    switch (i) {
      case 0:
        await _cleanProject();
        break;
      case 1:
        await _getPubDeps();
        break;
      case 2:
        await _generateCode();
        break;
      case 3:
        await _analyzeCode();
        break;
    }
  }

  print(ConsoleUtils.success('✅ 完整重建完成'));
}
