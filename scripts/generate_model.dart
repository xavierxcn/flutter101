#!/usr/bin/env dart

import 'dart:io';
import 'utils/file_utils.dart';
import 'utils/console_utils.dart';

/// 模型生成脚本
/// 快速生成 Freezed 数据模型
void main(List<String> args) async {
  print(ConsoleUtils.banner('📦 Freezed 模型生成器'));

  try {
    // 从命令行参数或交互式输入获取模型信息
    final modelInfo = args.isNotEmpty
        ? _parseArgsToModelInfo(args)
        : await _getModelInfoInteractive();

    // 确认生成信息
    if (!await _confirmGeneration(modelInfo)) {
      print(ConsoleUtils.warning('操作已取消'));
      return;
    }

    print(ConsoleUtils.info('开始生成模型...'));

    // 生成文件
    await _generateModel(modelInfo);

    print(ConsoleUtils.success('✅ 模型生成完成！'));
    print(ConsoleUtils.info('生成的文件：'));
    print('  - lib/app/data/models/${modelInfo.fileName}.dart');
    print('');
    print(ConsoleUtils.info('请运行以下命令生成代码：'));
    print('  flutter packages pub run build_runner build');
  } catch (e) {
    print(ConsoleUtils.error('❌ 生成失败: $e'));
    exit(1);
  }
}

class ModelField {
  final String name;
  final String type;
  final bool isRequired;
  final String? defaultValue;
  final String? description;
  final bool isNullable;

  ModelField({
    required this.name,
    required this.type,
    this.isRequired = true,
    this.defaultValue,
    this.description,
    this.isNullable = false,
  });

  String get dartType {
    final baseType = type;
    return isNullable ? '$baseType?' : baseType;
  }

  String get parameterDeclaration {
    final requiredKeyword = isRequired && !isNullable ? 'required ' : '';
    final defaultValueStr = defaultValue != null ? ' = $defaultValue' : '';
    return '$requiredKeyword$dartType $name$defaultValueStr';
  }
}

class ModelInfo {
  final String modelName;
  final String fileName;
  final String className;
  final String description;
  final List<ModelField> fields;
  final bool generateFromJson;
  final bool generateToJson;
  final bool generateCopyWith;
  final bool generateEquality;

  ModelInfo({
    required this.modelName,
    required this.fileName,
    required this.className,
    required this.description,
    required this.fields,
    this.generateFromJson = true,
    this.generateToJson = true,
    this.generateCopyWith = true,
    this.generateEquality = true,
  });
}

ModelInfo _parseArgsToModelInfo(List<String> args) {
  if (args.isEmpty) {
    throw Exception('使用方法: dart run scripts/generate_model.dart <model_name>');
  }

  final modelName = args[0];
  return ModelInfo(
    modelName: modelName,
    fileName: FileUtils.toFileName(modelName),
    className: FileUtils.toClassName(modelName),
    description: 'Generated model for $modelName',
    fields: [],
  );
}

Future<ModelInfo> _getModelInfoInteractive() async {
  print(ConsoleUtils.section('模型信息配置'));

  final modelName = ConsoleUtils.prompt(
    '模型名称 (例: user, product, order_item)',
    validator: (value) => _validateModelName(value),
  );

  final description = ConsoleUtils.prompt(
    '模型描述',
    defaultValue: _formatDescription(modelName),
  );

  print(ConsoleUtils.section('生成选项'));

  final generateFromJson = ConsoleUtils.confirm('是否生成 fromJson 方法？');
  final generateToJson = ConsoleUtils.confirm('是否生成 toJson 方法？');
  final generateCopyWith = ConsoleUtils.confirm('是否生成 copyWith 方法？');
  final generateEquality = ConsoleUtils.confirm('是否生成相等性比较？');

  // 添加字段
  final fields = await _addFields();

  return ModelInfo(
    modelName: modelName,
    fileName: FileUtils.toFileName(modelName),
    className: FileUtils.toClassName(modelName),
    description: description,
    fields: fields,
    generateFromJson: generateFromJson,
    generateToJson: generateToJson,
    generateCopyWith: generateCopyWith,
    generateEquality: generateEquality,
  );
}

String? _validateModelName(String value) {
  if (value.isEmpty) return '模型名称不能为空';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    return '模型名称必须以小写字母开头，只能包含小写字母、数字和下划线';
  }
  return null;
}

String _formatDescription(String modelName) {
  return '${FileUtils.toClassName(modelName)} data model';
}

Future<List<ModelField>> _addFields() async {
  print(ConsoleUtils.section('添加模型字段'));

  final fields = <ModelField>[];

  while (true) {
    print('\n--- 字段 ${fields.length + 1} ---');

    final name = ConsoleUtils.prompt(
      '字段名称 (留空结束)',
      validator: (value) => value.isEmpty ? null : _validateFieldName(value),
    );

    if (name.isEmpty) break;

    final type = _selectFieldType();
    final isNullable = ConsoleUtils.confirm('是否可为空？');
    final isRequired = !isNullable && ConsoleUtils.confirm('是否必需？');

    String? defaultValue;
    if (!isRequired || isNullable) {
      defaultValue = ConsoleUtils.prompt('默认值 (留空表示无默认值)');
      if (defaultValue.isEmpty) defaultValue = null;
    }

    final description = ConsoleUtils.prompt('字段描述 (可选)');

    fields.add(
      ModelField(
        name: name,
        type: type,
        isRequired: isRequired,
        defaultValue: defaultValue,
        description: description.isEmpty ? null : description,
        isNullable: isNullable,
      ),
    );

    print(ConsoleUtils.success('字段已添加: $name'));
  }

  return fields;
}

String? _validateFieldName(String value) {
  if (!FileUtils.isValidDartIdentifier(value)) {
    return '字段名称必须是有效的 Dart 标识符';
  }
  return null;
}

String _selectFieldType() {
  final commonTypes = [
    'String',
    'int',
    'double',
    'bool',
    'DateTime',
    'List<String>',
    'List<int>',
    'Map<String, dynamic>',
    '自定义类型',
  ];

  final choice = ConsoleUtils.menu('选择字段类型', commonTypes);

  if (choice == commonTypes.length - 1) {
    return ConsoleUtils.prompt('输入自定义类型');
  } else {
    return commonTypes[choice];
  }
}

Future<bool> _confirmGeneration(ModelInfo info) async {
  print(ConsoleUtils.section('确认生成信息'));
  print('模型名称: ${info.modelName}');
  print('类名: ${info.className}');
  print('文件名: ${info.fileName}.dart');
  print('描述: ${info.description}');
  print('字段数量: ${info.fields.length}');

  if (info.fields.isNotEmpty) {
    print('\n字段列表:');
    for (final field in info.fields) {
      final requiredStr = field.isRequired ? ' (必需)' : '';
      final defaultStr = field.defaultValue != null
          ? ' = ${field.defaultValue}'
          : '';
      print('  - ${field.name}: ${field.dartType}$requiredStr$defaultStr');
    }
  }

  print('\n生成选项:');
  print('  fromJson: ${info.generateFromJson ? '是' : '否'}');
  print('  toJson: ${info.generateToJson ? '是' : '否'}');
  print('  copyWith: ${info.generateCopyWith ? '是' : '否'}');
  print('  相等性比较: ${info.generateEquality ? '是' : '否'}');
  print('');

  return ConsoleUtils.confirm('确认生成模型？');
}

Future<void> _generateModel(ModelInfo info) async {
  print(ConsoleUtils.step('生成模型文件'));

  final dirPath = 'lib/app/data/models';
  await FileUtils.ensureDirectory(dirPath);

  final content = _generateModelContent(info);
  final filePath = '$dirPath/${info.fileName}.dart';

  await File(filePath).writeAsString(content);
}

String _generateModelContent(ModelInfo info) {
  final imports = <String>[
    "import 'package:freezed_annotation/freezed_annotation.dart';",
  ];

  final parts = <String>["part '${info.fileName}.freezed.dart';"];

  if (info.generateFromJson || info.generateToJson) {
    parts.add("part '${info.fileName}.g.dart';");
  }

  // 检查是否需要特殊导入
  final needsDateTimeConverter = info.fields.any((f) => f.type == 'DateTime');
  if (needsDateTimeConverter) {
    // 可以添加自定义的 DateTime 转换器导入
  }

  final constructor = _generateConstructor(info);
  final factoryMethods = _generateFactoryMethods(info);

  return '''${imports.join('\n')}

${parts.join('\n')}

/// ${info.description}
@freezed
class ${info.className} with _\$${info.className} {
  const factory ${info.className}({
$constructor
  }) = _${info.className};
$factoryMethods
}
''';
}

String _generateConstructor(ModelInfo info) {
  if (info.fields.isEmpty) {
    return '';
  }

  final fieldLines = <String>[];

  for (final field in info.fields) {
    final lines = <String>[];

    // 添加注释
    if (field.description != null) {
      lines.add('    /// ${field.description}');
    }

    // 添加注解
    final annotations = <String>[];

    if (field.defaultValue != null) {
      annotations.add('@Default(${field.defaultValue})');
    }

    // JSON 字段名注解
    if (field.name.contains('_')) {
      final jsonKey = field.name;
      annotations.add("@JsonKey(name: '$jsonKey')");
    }

    if (annotations.isNotEmpty) {
      lines.addAll(annotations.map((a) => '    $a'));
    }

    // 字段声明
    lines.add('    ${field.parameterDeclaration},');

    fieldLines.addAll(lines);
  }

  return fieldLines.join('\n');
}

String _generateFactoryMethods(ModelInfo info) {
  final methods = <String>[];

  if (info.generateFromJson) {
    methods.add('''
  /// 从 JSON 创建实例
  factory ${info.className}.fromJson(Map<String, dynamic> json) =>
      _\$${info.className}FromJson(json);''');
  }

  // 添加一些便利的工厂方法
  if (info.fields.isNotEmpty) {
    methods.add('''
  /// 创建空实例
  factory ${info.className}.empty() => const ${info.className}();''');
  }

  return methods.isEmpty ? '' : '\n${methods.join('\n')}';
}

// 预设的模型模板
final modelTemplates = {
  'user': ModelInfo(
    modelName: 'user',
    fileName: 'user',
    className: 'User',
    description: 'User data model',
    fields: [
      ModelField(name: 'id', type: 'String'),
      ModelField(name: 'name', type: 'String'),
      ModelField(name: 'email', type: 'String'),
      ModelField(name: 'avatar', type: 'String', isNullable: true),
      ModelField(name: 'createdAt', type: 'DateTime'),
      ModelField(name: 'isActive', type: 'bool', defaultValue: 'true'),
    ],
  ),

  'product': ModelInfo(
    modelName: 'product',
    fileName: 'product',
    className: 'Product',
    description: 'Product data model',
    fields: [
      ModelField(name: 'id', type: 'String'),
      ModelField(name: 'name', type: 'String'),
      ModelField(name: 'description', type: 'String'),
      ModelField(name: 'price', type: 'double'),
      ModelField(name: 'imageUrl', type: 'String', isNullable: true),
      ModelField(name: 'category', type: 'String'),
      ModelField(name: 'isAvailable', type: 'bool', defaultValue: 'true'),
    ],
  ),

  'api_response': ModelInfo(
    modelName: 'api_response',
    fileName: 'api_response',
    className: 'ApiResponse',
    description: 'Generic API response model',
    fields: [
      ModelField(name: 'success', type: 'bool'),
      ModelField(name: 'message', type: 'String', isNullable: true),
      ModelField(name: 'data', type: 'T', isNullable: true),
      ModelField(name: 'errors', type: 'List<String>', isNullable: true),
    ],
  ),
};
