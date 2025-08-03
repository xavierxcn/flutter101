import 'dart:io';

/// 文件操作工具类
class FileUtils {
  /// 递归复制目录
  static Future<void> copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    if (!destination.existsSync()) {
      await destination.create(recursive: true);
    }

    await for (final entity in source.list()) {
      if (entity is Directory) {
        final newDirectory = Directory(
          '${destination.path}/${entity.uri.pathSegments.last}',
        );
        await copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        final newFile = File(
          '${destination.path}/${entity.uri.pathSegments.last}',
        );
        await entity.copy(newFile.path);
      }
    }
  }

  /// 递归删除目录
  static Future<void> deleteDirectory(Directory directory) async {
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }

  /// 确保目录存在
  static Future<void> ensureDirectory(String path) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  /// 替换文件中的文本
  static Future<void> replaceInFile(
    String filePath,
    Map<String, String> replacements,
  ) async {
    final file = File(filePath);
    if (!file.existsSync()) return;

    String content = await file.readAsString();

    for (final entry in replacements.entries) {
      content = content.replaceAll(entry.key, entry.value);
    }

    await file.writeAsString(content);
  }

  /// 在文件中的指定位置插入文本
  static Future<void> insertInFile(
    String filePath,
    String marker,
    String insertion, {
    bool after = true,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) return;

    final lines = await file.readAsLines();
    final insertIndex = lines.indexWhere((line) => line.contains(marker));

    if (insertIndex != -1) {
      final targetIndex = after ? insertIndex + 1 : insertIndex;
      lines.insert(targetIndex, insertion);
      await file.writeAsString(lines.join('\n') + '\n');
    }
  }

  /// 检查文件是否包含指定文本
  static Future<bool> fileContains(String filePath, String text) async {
    final file = File(filePath);
    if (!file.existsSync()) return false;

    final content = await file.readAsString();
    return content.contains(text);
  }

  /// 获取文件中匹配正则表达式的行
  static Future<List<String>> findLinesMatching(
    String filePath,
    RegExp pattern,
  ) async {
    final file = File(filePath);
    if (!file.existsSync()) return [];

    final lines = await file.readAsLines();
    return lines.where((line) => pattern.hasMatch(line)).toList();
  }

  /// 将字符串转换为适合文件名的格式
  static String toFileName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// 将字符串转换为类名格式
  static String toClassName(String name) {
    return name
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  /// 将字符串转换为变量名格式
  static String toVariableName(String name) {
    final className = toClassName(name);
    return className.isNotEmpty
        ? className[0].toLowerCase() + className.substring(1)
        : '';
  }

  /// 将类名转换为文件名
  static String classNameToFileName(String className) {
    return className
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => '_${match.group(1)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }

  /// 检查是否为有效的 Dart 标识符
  static bool isValidDartIdentifier(String name) {
    return RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(name);
  }

  /// 读取模板文件并替换占位符
  static Future<String> processTemplate(
    String templatePath,
    Map<String, String> variables,
  ) async {
    final file = File(templatePath);
    if (!file.existsSync()) {
      throw Exception('模板文件不存在: $templatePath');
    }

    String content = await file.readAsString();

    for (final entry in variables.entries) {
      content = content.replaceAll('{{${entry.key}}}', entry.value);
    }

    return content;
  }

  /// 获取项目根目录
  static Directory getProjectRoot() {
    Directory current = Directory.current;

    while (current.path != current.parent.path) {
      if (File('${current.path}/pubspec.yaml').existsSync()) {
        return current;
      }
      current = current.parent;
    }

    throw Exception('无法找到项目根目录 (pubspec.yaml 不存在)');
  }

  /// 获取相对于项目根目录的路径
  static String getRelativePath(String absolutePath) {
    final projectRoot = getProjectRoot().path;
    if (absolutePath.startsWith(projectRoot)) {
      return absolutePath.substring(projectRoot.length + 1);
    }
    return absolutePath;
  }
}
