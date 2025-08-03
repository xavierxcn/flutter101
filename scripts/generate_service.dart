#!/usr/bin/env dart

import 'dart:io';
import 'utils/file_utils.dart';
import 'utils/console_utils.dart';

/// 服务生成脚本
/// 快速生成新的服务类
void main(List<String> args) async {
  print(ConsoleUtils.banner('⚙️ 服务生成器'));

  try {
    // 从命令行参数或交互式输入获取服务信息
    final serviceInfo = args.isNotEmpty
        ? _parseArgsToServiceInfo(args)
        : await _getServiceInfoInteractive();

    // 确认生成信息
    if (!await _confirmGeneration(serviceInfo)) {
      print(ConsoleUtils.warning('操作已取消'));
      return;
    }

    print(ConsoleUtils.info('开始生成服务...'));

    // 生成文件
    await _generateService(serviceInfo);

    print(ConsoleUtils.success('✅ 服务生成完成！'));
    print(ConsoleUtils.info('生成的文件：'));
    print('  - ${serviceInfo.filePath}');
    print('');
    print(ConsoleUtils.info('使用方法：'));
    print('  1. 在 DependencyInjection 中注册服务');
    print('  2. 在需要的地方使用 Get.find<${serviceInfo.className}>()');
  } catch (e) {
    print(ConsoleUtils.error('❌ 生成失败: $e'));
    exit(1);
  }
}

enum ServiceType {
  api('API 服务', 'lib/app/data/services'),
  core('核心服务', 'lib/app/core/services'),
  feature('功能服务', 'lib/features');

  const ServiceType(this.displayName, this.basePath);

  final String displayName;
  final String basePath;
}

class ServiceMethod {
  final String name;
  final String returnType;
  final List<ServiceParameter> parameters;
  final String description;
  final bool isAsync;

  ServiceMethod({
    required this.name,
    required this.returnType,
    this.parameters = const [],
    required this.description,
    this.isAsync = true,
  });
}

class ServiceParameter {
  final String name;
  final String type;
  final bool isRequired;
  final String? defaultValue;

  ServiceParameter({
    required this.name,
    required this.type,
    this.isRequired = true,
    this.defaultValue,
  });

  String get declaration {
    final requiredKeyword = isRequired ? 'required ' : '';
    final defaultValueStr = defaultValue != null ? ' = $defaultValue' : '';
    return '$requiredKeyword$type $name$defaultValueStr';
  }
}

class ServiceInfo {
  final String serviceName;
  final String fileName;
  final String className;
  final String description;
  final ServiceType type;
  final String filePath;
  final List<String> dependencies;
  final List<ServiceMethod> methods;
  final bool extendsGetxService;
  final bool isSingleton;

  ServiceInfo({
    required this.serviceName,
    required this.fileName,
    required this.className,
    required this.description,
    required this.type,
    required this.filePath,
    this.dependencies = const [],
    this.methods = const [],
    this.extendsGetxService = true,
    this.isSingleton = true,
  });
}

ServiceInfo _parseArgsToServiceInfo(List<String> args) {
  if (args.isEmpty) {
    throw Exception(
      '使用方法: dart run scripts/generate_service.dart <service_name>',
    );
  }

  final serviceName = args[0];
  final type = args.length > 1 ? _parseServiceType(args[1]) : ServiceType.api;

  return _createServiceInfo(serviceName, type);
}

ServiceType _parseServiceType(String typeStr) {
  switch (typeStr.toLowerCase()) {
    case 'api':
      return ServiceType.api;
    case 'core':
      return ServiceType.core;
    case 'feature':
      return ServiceType.feature;
    default:
      throw Exception('未知的服务类型: $typeStr');
  }
}

Future<ServiceInfo> _getServiceInfoInteractive() async {
  print(ConsoleUtils.section('服务信息配置'));

  final serviceName = ConsoleUtils.prompt(
    '服务名称 (例: user_api, cache_manager)',
    validator: (value) => _validateServiceName(value),
  );

  final typeIndex = ConsoleUtils.menu(
    '选择服务类型',
    ServiceType.values.map((t) => t.displayName).toList(),
  );
  final type = ServiceType.values[typeIndex];

  final description = ConsoleUtils.prompt(
    '服务描述',
    defaultValue: _formatDescription(serviceName),
  );

  final extendsGetxService = ConsoleUtils.confirm('是否继承 GetxService？');
  final isSingleton = ConsoleUtils.confirm('是否为单例服务？');

  // 选择依赖服务
  final dependencies = await _selectDependencies();

  // 添加方法
  final methods = await _addMethods();

  final serviceInfo = _createServiceInfo(serviceName, type);

  return ServiceInfo(
    serviceName: serviceInfo.serviceName,
    fileName: serviceInfo.fileName,
    className: serviceInfo.className,
    description: description,
    type: type,
    filePath: serviceInfo.filePath,
    dependencies: dependencies,
    methods: methods,
    extendsGetxService: extendsGetxService,
    isSingleton: isSingleton,
  );
}

ServiceInfo _createServiceInfo(String serviceName, ServiceType type) {
  final fileName = FileUtils.toFileName(serviceName);
  final className = FileUtils.toClassName(serviceName);

  String filePath;
  if (type == ServiceType.feature) {
    final featureName = fileName.split('_').first;
    filePath = '${type.basePath}/$featureName/services/${fileName}.dart';
  } else {
    filePath = '${type.basePath}/${fileName}.dart';
  }

  return ServiceInfo(
    serviceName: serviceName,
    fileName: fileName,
    className: className,
    description: _formatDescription(serviceName),
    type: type,
    filePath: filePath,
  );
}

String? _validateServiceName(String value) {
  if (value.isEmpty) return '服务名称不能为空';
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
    return '服务名称必须以小写字母开头，只能包含小写字母、数字和下划线';
  }
  return null;
}

String _formatDescription(String serviceName) {
  return '${FileUtils.toClassName(serviceName)} service';
}

Future<List<String>> _selectDependencies() async {
  final availableServices = [
    'NetworkService',
    'LocalizationService',
    'GetStorage',
  ];

  print('\n选择需要注入的依赖 (可多选):');
  final indices = ConsoleUtils.multiSelect('依赖服务', availableServices);

  return indices.map((i) => availableServices[i]).toList();
}

Future<List<ServiceMethod>> _addMethods() async {
  print(ConsoleUtils.section('添加服务方法'));

  final methods = <ServiceMethod>[];

  while (true) {
    print('\n--- 方法 ${methods.length + 1} ---');

    final name = ConsoleUtils.prompt(
      '方法名称 (留空结束)',
      validator: (value) => value.isEmpty ? null : _validateMethodName(value),
    );

    if (name.isEmpty) break;

    final returnType = ConsoleUtils.prompt(
      '返回类型',
      defaultValue: 'Future<void>',
    );

    final description = ConsoleUtils.prompt(
      '方法描述',
      defaultValue: _formatMethodDescription(name),
    );

    final isAsync = ConsoleUtils.confirm('是否为异步方法？');

    // 添加参数
    final parameters = await _addMethodParameters();

    methods.add(
      ServiceMethod(
        name: name,
        returnType: returnType,
        parameters: parameters,
        description: description,
        isAsync: isAsync,
      ),
    );

    print(ConsoleUtils.success('方法已添加: $name'));
  }

  return methods;
}

String? _validateMethodName(String value) {
  if (!FileUtils.isValidDartIdentifier(value)) {
    return '方法名称必须是有效的 Dart 标识符';
  }
  return null;
}

String _formatMethodDescription(String methodName) {
  return FileUtils.toClassName(methodName)
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(1)!.toLowerCase()}',
      )
      .trim();
}

Future<List<ServiceParameter>> _addMethodParameters() async {
  final parameters = <ServiceParameter>[];

  print('\n添加方法参数:');

  while (true) {
    final name = ConsoleUtils.prompt(
      '参数名称 (留空结束)',
      validator: (value) =>
          value.isEmpty ? null : _validateParameterName(value),
    );

    if (name.isEmpty) break;

    final type = ConsoleUtils.prompt('参数类型', defaultValue: 'String');
    final isRequired = ConsoleUtils.confirm('是否必需？');

    String? defaultValue;
    if (!isRequired) {
      defaultValue = ConsoleUtils.prompt('默认值 (留空表示无默认值)');
      if (defaultValue.isEmpty) defaultValue = null;
    }

    parameters.add(
      ServiceParameter(
        name: name,
        type: type,
        isRequired: isRequired,
        defaultValue: defaultValue,
      ),
    );

    print(ConsoleUtils.success('参数已添加: $name'));
  }

  return parameters;
}

String? _validateParameterName(String value) {
  if (!FileUtils.isValidDartIdentifier(value)) {
    return '参数名称必须是有效的 Dart 标识符';
  }
  return null;
}

Future<bool> _confirmGeneration(ServiceInfo info) async {
  print(ConsoleUtils.section('确认生成信息'));
  print('服务名称: ${info.serviceName}');
  print('类名: ${info.className}');
  print('类型: ${info.type.displayName}');
  print('文件路径: ${info.filePath}');
  print('描述: ${info.description}');
  print('继承 GetxService: ${info.extendsGetxService ? '是' : '否'}');
  print('单例服务: ${info.isSingleton ? '是' : '否'}');

  if (info.dependencies.isNotEmpty) {
    print('依赖服务: ${info.dependencies.join(', ')}');
  }

  if (info.methods.isNotEmpty) {
    print('\n方法列表:');
    for (final method in info.methods) {
      final params = method.parameters
          .map((p) => '${p.type} ${p.name}')
          .join(', ');
      print('  - ${method.name}($params): ${method.returnType}');
    }
  }

  print('');

  return ConsoleUtils.confirm('确认生成服务？');
}

Future<void> _generateService(ServiceInfo info) async {
  print(ConsoleUtils.step('生成服务文件'));

  final dirPath = File(info.filePath).parent.path;
  await FileUtils.ensureDirectory(dirPath);

  final content = _generateServiceContent(info);

  await File(info.filePath).writeAsString(content);
}

String _generateServiceContent(ServiceInfo info) {
  final imports = <String>[];

  if (info.extendsGetxService) {
    imports.add("import 'package:get/get.dart';");
  }

  if (info.dependencies.contains('GetStorage')) {
    imports.add("import 'package:get_storage/get_storage.dart';");
  }

  if (info.dependencies.contains('NetworkService')) {
    imports.add("import '../network_service.dart';");
  }

  if (info.dependencies.contains('LocalizationService')) {
    imports.add("import '../localization_service.dart';");
  }

  final classDeclaration = info.extendsGetxService
      ? '${info.className} extends GetxService'
      : info.className;

  final dependencies = info.dependencies
      .map(
        (dep) => '  final ${dep} _${dep.toLowerCase()} = Get.find<${dep}>();',
      )
      .join('\n');

  final methods = info.methods
      .map((method) => _generateMethod(method))
      .join('\n\n');

  final lifecycle = info.extendsGetxService
      ? '''
  
  @override
  void onInit() {
    super.onInit();
    // 初始化操作
  }
  
  @override
  void onClose() {
    super.onClose();
    // 清理资源
  }'''
      : '';

  return '''${imports.join('\n')}

/// ${info.description}
class $classDeclaration {${dependencies.isNotEmpty ? '\n$dependencies' : ''}$lifecycle${methods.isNotEmpty ? '\n\n$methods' : ''}
}
''';
}

String _generateMethod(ServiceMethod method) {
  final asyncKeyword = method.isAsync ? 'async ' : '';
  final parameters = method.parameters.map((p) => p.declaration).join(', ');

  final methodBody = method.isAsync
      ? '''
    try {
      // TODO: 实现 ${method.description}
      
    } catch (e) {
      Get.log('${method.name} 失败: \$e');
      rethrow;
    }'''
      : '''
    // TODO: 实现 ${method.description}
    throw UnimplementedError();''';

  return '''  /// ${method.description}
  ${method.returnType} ${method.name}($parameters) $asyncKeyword{$methodBody
  }''';
}

// 预设的服务模板
final serviceTemplates = {
  'user_api': ServiceInfo(
    serviceName: 'user_api',
    fileName: 'user_api_service',
    className: 'UserApiService',
    description: 'User API service',
    type: ServiceType.api,
    filePath: 'lib/app/data/services/user_api_service.dart',
    dependencies: ['NetworkService'],
    methods: [
      ServiceMethod(
        name: 'getUser',
        returnType: 'Future<User>',
        parameters: [ServiceParameter(name: 'id', type: 'String')],
        description: '获取用户信息',
      ),
      ServiceMethod(
        name: 'updateUser',
        returnType: 'Future<User>',
        parameters: [ServiceParameter(name: 'user', type: 'User')],
        description: '更新用户信息',
      ),
    ],
  ),

  'cache_manager': ServiceInfo(
    serviceName: 'cache_manager',
    fileName: 'cache_manager',
    className: 'CacheManager',
    description: 'Cache management service',
    type: ServiceType.core,
    filePath: 'lib/app/core/services/cache_manager.dart',
    dependencies: ['GetStorage'],
    methods: [
      ServiceMethod(
        name: 'get',
        returnType: 'T?',
        parameters: [ServiceParameter(name: 'key', type: 'String')],
        description: '获取缓存数据',
        isAsync: false,
      ),
      ServiceMethod(
        name: 'set',
        returnType: 'Future<void>',
        parameters: [
          ServiceParameter(name: 'key', type: 'String'),
          ServiceParameter(name: 'value', type: 'dynamic'),
        ],
        description: '设置缓存数据',
      ),
    ],
  ),
};
