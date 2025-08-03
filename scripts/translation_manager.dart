#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'utils/console_utils.dart';

/// 翻译管理脚本
/// 检查翻译完整性、添加新翻译、导出翻译等功能
void main(List<String> args) async {
  print(ConsoleUtils.banner('🌐 翻译管理器'));

  if (args.isEmpty) {
    await _showMainMenu();
  } else {
    await _handleCommand(args);
  }
}

Future<void> _showMainMenu() async {
  while (true) {
    final options = [
      '检查翻译完整性',
      '添加新翻译',
      '查找未使用的翻译',
      '导出翻译到 JSON',
      '从 JSON 导入翻译',
      '统计翻译信息',
      '退出',
    ];

    final choice = ConsoleUtils.menu('请选择操作', options);

    try {
      switch (choice) {
        case 0:
          await _checkTranslationCompleteness();
          break;
        case 1:
          await _addNewTranslation();
          break;
        case 2:
          await _findUnusedTranslations();
          break;
        case 3:
          await _exportTranslations();
          break;
        case 4:
          await _importTranslations();
          break;
        case 5:
          await _showTranslationStats();
          break;
        case 6:
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
    case 'check':
      await _checkTranslationCompleteness();
      break;
    case 'add':
      if (args.length < 4) {
        print(
          '使用方法: dart run scripts/translation_manager.dart add <key> <en_text> <zh_text>',
        );
        exit(1);
      }
      await _addTranslationFromArgs(args[1], args[2], args[3]);
      break;
    case 'export':
      await _exportTranslations();
      break;
    case 'import':
      if (args.length < 2) {
        print(
          '使用方法: dart run scripts/translation_manager.dart import <json_file>',
        );
        exit(1);
      }
      await _importTranslationsFromFile(args[1]);
      break;
    case 'stats':
      await _showTranslationStats();
      break;
    default:
      print('未知命令: ${args[0]}');
      print('可用命令: check, add, export, import, stats');
      exit(1);
  }
}

class TranslationData {
  final Map<String, Map<String, String>> translations;

  TranslationData(this.translations);

  Set<String> get allKeys =>
      translations.values.expand((langMap) => langMap.keys).toSet();

  Set<String> get languages => translations.keys.toSet();

  Set<String> getMissingKeys(String language) {
    final langKeys = translations[language]?.keys.toSet() ?? <String>{};
    return allKeys.difference(langKeys);
  }

  Set<String> getExtraKeys(String language) {
    final langKeys = translations[language]?.keys.toSet() ?? <String>{};
    final otherKeys = translations.entries
        .where((entry) => entry.key != language)
        .expand((entry) => entry.value.keys)
        .toSet();
    return langKeys.difference(otherKeys);
  }
}

Future<TranslationData> _loadTranslations() async {
  final file = File('lib/app/localization/app_translations.dart');
  if (!file.existsSync()) {
    throw Exception('翻译文件不存在: ${file.path}');
  }

  final content = await file.readAsString();
  final translations = <String, Map<String, String>>{};

  // 解析翻译内容
  final pattern = RegExp(r"'([^']+)':\s*\{([^}]+)\}", multiLine: true);
  final matches = pattern.allMatches(content);

  for (final match in matches) {
    final language = match.group(1)!;
    final entriesText = match.group(2)!;

    final entryPattern = RegExp(r"'([^']+)':\s*'([^']*)'");
    final entryMatches = entryPattern.allMatches(entriesText);

    final langMap = <String, String>{};
    for (final entryMatch in entryMatches) {
      final key = entryMatch.group(1)!;
      final value = entryMatch.group(2)!;
      langMap[key] = value;
    }

    translations[language] = langMap;
  }

  return TranslationData(translations);
}

Future<void> _checkTranslationCompleteness() async {
  print(ConsoleUtils.section('检查翻译完整性'));

  final data = await _loadTranslations();
  final languages = data.languages.toList()..sort();

  bool hasIssues = false;

  for (final language in languages) {
    final missing = data.getMissingKeys(language);
    final extra = data.getExtraKeys(language);

    if (missing.isNotEmpty) {
      hasIssues = true;
      print(ConsoleUtils.error('$language 缺少翻译:'));
      for (final key in missing) {
        print('  - $key');
      }
      print('');
    }

    if (extra.isNotEmpty) {
      hasIssues = true;
      print(ConsoleUtils.warning('$language 多余翻译:'));
      for (final key in extra) {
        print('  - $key');
      }
      print('');
    }
  }

  if (!hasIssues) {
    print(ConsoleUtils.success('✅ 所有翻译都是完整的！'));
  }

  // 显示统计信息
  print(ConsoleUtils.info('翻译统计:'));
  for (final language in languages) {
    final count = data.translations[language]?.length ?? 0;
    print('  $language: $count 条翻译');
  }
}

Future<void> _addNewTranslation() async {
  print(ConsoleUtils.section('添加新翻译'));

  final key = ConsoleUtils.prompt(
    '翻译键名',
    validator: (value) => _validateTranslationKey(value),
  );

  final data = await _loadTranslations();
  final languages = data.languages.toList()..sort();

  final translations = <String, String>{};

  for (final language in languages) {
    final languageName = _getLanguageName(language);
    final text = ConsoleUtils.prompt('$languageName 翻译');
    translations[language] = text;
  }

  // 确认添加
  print('\n确认添加以下翻译:');
  print('键名: $key');
  for (final entry in translations.entries) {
    final languageName = _getLanguageName(entry.key);
    print('$languageName: ${entry.value}');
  }

  if (!ConsoleUtils.confirm('\n确认添加？')) {
    print(ConsoleUtils.warning('操作已取消'));
    return;
  }

  await _addTranslationToFile(key, translations);
  print(ConsoleUtils.success('✅ 翻译已添加'));
}

Future<void> _addTranslationFromArgs(
  String key,
  String enText,
  String zhText,
) async {
  final translations = {'en_US': enText, 'zh_CN': zhText};

  await _addTranslationToFile(key, translations);
  print(ConsoleUtils.success('✅ 翻译已添加: $key'));
}

Future<void> _addTranslationToFile(
  String key,
  Map<String, String> translations,
) async {
  final file = File('lib/app/localization/app_translations.dart');
  String content = await file.readAsString();

  for (final entry in translations.entries) {
    final language = entry.key;
    final text = entry.value.replaceAll("'", "\\'");

    final pattern = RegExp("('$language':\\s*\\{[^}]+)(\\s*\\})");
    final match = pattern.firstMatch(content);

    if (match != null) {
      final before = match.group(1)!;
      final after = match.group(2)!;
      final newEntry = "          '$key': '$text',\n        ";
      content = content.replaceFirst(pattern, "$before\n$newEntry$after");
    }
  }

  await file.writeAsString(content);
}

String? _validateTranslationKey(String value) {
  if (value.isEmpty) return '翻译键名不能为空';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    return '翻译键名必须以小写字母开头，只能包含小写字母、数字和下划线';
  }
  return null;
}

String _getLanguageName(String languageCode) {
  switch (languageCode) {
    case 'en_US':
      return '英文';
    case 'zh_CN':
      return '中文';
    default:
      return languageCode;
  }
}

Future<void> _findUnusedTranslations() async {
  print(ConsoleUtils.section('查找未使用的翻译'));

  final data = await _loadTranslations();
  final allKeys = data.allKeys;

  // 扫描所有 .dart 文件
  final dartFiles = await _findDartFiles();
  final usedKeys = <String>{};

  print(ConsoleUtils.info('扫描 ${dartFiles.length} 个 Dart 文件...'));

  for (final file in dartFiles) {
    final content = await File(file).readAsString();

    for (final key in allKeys) {
      if (content.contains("'$key'.tr") || content.contains('"$key".tr')) {
        usedKeys.add(key);
      }
    }
  }

  final unusedKeys = allKeys.difference(usedKeys);

  if (unusedKeys.isEmpty) {
    print(ConsoleUtils.success('✅ 没有找到未使用的翻译'));
  } else {
    print(ConsoleUtils.warning('发现 ${unusedKeys.length} 个未使用的翻译:'));
    for (final key in unusedKeys.toList()..sort()) {
      print('  - $key');
    }

    if (ConsoleUtils.confirm('\n是否删除这些未使用的翻译？')) {
      await _removeTranslations(unusedKeys);
      print(ConsoleUtils.success('✅ 已删除未使用的翻译'));
    }
  }
}

Future<List<String>> _findDartFiles() async {
  final dartFiles = <String>[];

  await for (final entity in Directory('lib').list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity.path);
    }
  }

  return dartFiles;
}

Future<void> _removeTranslations(Set<String> keysToRemove) async {
  final file = File('lib/app/localization/app_translations.dart');
  String content = await file.readAsString();

  for (final key in keysToRemove) {
    // 移除翻译条目
    content = content.replaceAll(RegExp("\\s*'$key':\\s*'[^']*',?\\n"), '');
  }

  await file.writeAsString(content);
}

Future<void> _exportTranslations() async {
  print(ConsoleUtils.section('导出翻译到 JSON'));

  final data = await _loadTranslations();

  final outputPath = ConsoleUtils.prompt(
    '输出文件路径',
    defaultValue: 'translations.json',
  );

  final jsonData = <String, Map<String, String>>{};

  for (final entry in data.translations.entries) {
    jsonData[entry.key] = Map.from(entry.value);
  }

  final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
  await File(outputPath).writeAsString(jsonString);

  print(ConsoleUtils.success('✅ 翻译已导出到 $outputPath'));
}

Future<void> _importTranslations() async {
  print(ConsoleUtils.section('从 JSON 导入翻译'));

  final inputPath = ConsoleUtils.prompt('JSON 文件路径');
  await _importTranslationsFromFile(inputPath);
}

Future<void> _importTranslationsFromFile(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('文件不存在: $filePath');
  }

  final jsonString = await file.readAsString();
  final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

  print(ConsoleUtils.info('解析翻译数据...'));

  int addedCount = 0;

  for (final langEntry in jsonData.entries) {
    final language = langEntry.key;
    final translations = langEntry.value as Map<String, dynamic>;

    for (final transEntry in translations.entries) {
      final key = transEntry.key;
      final value = transEntry.value.toString();

      // 检查翻译是否已存在
      final existingData = await _loadTranslations();
      if (!(existingData.translations[language]?.containsKey(key) ?? false)) {
        await _addTranslationToFile(key, {language: value});
        addedCount++;
      }
    }
  }

  print(ConsoleUtils.success('✅ 已导入 $addedCount 条新翻译'));
}

Future<void> _showTranslationStats() async {
  print(ConsoleUtils.section('翻译统计信息'));

  final data = await _loadTranslations();
  final languages = data.languages.toList()..sort();

  print('支持的语言: ${languages.length}');
  for (final language in languages) {
    final languageName = _getLanguageName(language);
    print('  - $languageName ($language)');
  }

  print('\n翻译条目统计:');
  for (final language in languages) {
    final count = data.translations[language]?.length ?? 0;
    final languageName = _getLanguageName(language);
    print('  $languageName: $count 条');
  }

  print('\n总翻译键: ${data.allKeys.length}');

  // 检查完整性
  bool hasIssues = false;
  for (final language in languages) {
    final missing = data.getMissingKeys(language);
    if (missing.isNotEmpty) {
      hasIssues = true;
      break;
    }
  }

  print('翻译完整性: ${hasIssues ? '❌ 不完整' : '✅ 完整'}');

  // 最长和最短的翻译键
  final allKeys = data.allKeys.toList()..sort();
  if (allKeys.isNotEmpty) {
    final longestKey = allKeys.reduce((a, b) => a.length > b.length ? a : b);
    final shortestKey = allKeys.reduce((a, b) => a.length < b.length ? a : b);

    print('\n键名长度:');
    print('  最长: $longestKey (${longestKey.length} 字符)');
    print('  最短: $shortestKey (${shortestKey.length} 字符)');
  }
}
