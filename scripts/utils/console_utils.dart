import 'dart:io';

/// 控制台工具类，用于美化输出和用户交互
class ConsoleUtils {
  // ANSI 颜色代码
  static const String _reset = '\x1b[0m';
  static const String _red = '\x1b[31m';
  static const String _green = '\x1b[32m';
  static const String _yellow = '\x1b[33m';
  static const String _blue = '\x1b[34m';
  static const String _magenta = '\x1b[35m';
  static const String _cyan = '\x1b[36m';
  static const String _bold = '\x1b[1m';

  /// 显示横幅
  static String banner(String text) {
    final line = '=' * (text.length + 4);
    return '$_cyan$_bold$line\n  $text  \n$line$_reset';
  }

  /// 显示章节标题
  static String section(String text) {
    return '\n$_blue$_bold📋 $text$_reset\n${'─' * (text.length + 3)}';
  }

  /// 显示步骤
  static String step(String text) {
    return '$_magenta🔧 $text$_reset';
  }

  /// 显示成功消息
  static String success(String text) {
    return '$_green$text$_reset';
  }

  /// 显示错误消息
  static String error(String text) {
    return '$_red$text$_reset';
  }

  /// 显示警告消息
  static String warning(String text) {
    return '$_yellow$text$_reset';
  }

  /// 显示信息消息
  static String info(String text) {
    return '$_cyan$text$_reset';
  }

  /// 提示用户输入
  static String prompt(
    String message, {
    String? defaultValue,
    String? Function(String)? validator,
  }) {
    while (true) {
      final hint = defaultValue != null ? ' [$defaultValue]' : '';
      stdout.write('$_yellow?$_reset $message$hint: ');

      final input = stdin.readLineSync() ?? '';
      final value = input.trim().isEmpty ? (defaultValue ?? '') : input.trim();

      if (validator != null) {
        final error = validator(value);
        if (error != null) {
          print(ConsoleUtils.error('  ❌ $error'));
          continue;
        }
      }

      return value;
    }
  }

  /// 确认对话框
  static bool confirm(String message) {
    while (true) {
      stdout.write('$_yellow?$_reset $message (y/N): ');
      final input = stdin.readLineSync()?.toLowerCase().trim() ?? '';

      if (input == 'y' || input == 'yes') {
        return true;
      } else if (input == 'n' || input == 'no' || input.isEmpty) {
        return false;
      } else {
        print(ConsoleUtils.error('  请输入 y 或 n'));
      }
    }
  }

  /// 单选菜单
  static int menu(String title, List<String> options) {
    print(section(title));

    for (int i = 0; i < options.length; i++) {
      print('  ${i + 1}. ${options[i]}');
    }

    while (true) {
      stdout.write('$_yellow?$_reset 请选择 (1-${options.length}): ');
      final input = stdin.readLineSync()?.trim() ?? '';

      final choice = int.tryParse(input);
      if (choice != null && choice >= 1 && choice <= options.length) {
        return choice - 1;
      } else {
        print(error('  请输入有效的选项编号'));
      }
    }
  }

  /// 多选菜单
  static List<int> multiSelect(String title, List<String> options) {
    print(section(title));

    for (int i = 0; i < options.length; i++) {
      print('  ${i + 1}. ${options[i]}');
    }

    print('\n输入多个选项编号，用逗号分隔 (例: 1,3,5)');

    while (true) {
      stdout.write('$_yellow?$_reset 请选择: ');
      final input = stdin.readLineSync()?.trim() ?? '';

      if (input.isEmpty) {
        return [];
      }

      try {
        final choices = input
            .split(',')
            .map((s) => int.parse(s.trim()))
            .where((i) => i >= 1 && i <= options.length)
            .map((i) => i - 1)
            .toList();

        if (choices.isNotEmpty) {
          return choices;
        }
      } catch (e) {
        // 继续循环
      }

      print(error('  请输入有效的选项编号'));
    }
  }

  /// 显示进度条
  static void progress(String message, int current, int total) {
    const int barLength = 30;
    final double progress = current / total;
    final int filledLength = (barLength * progress).round();

    final String bar = '█' * filledLength + '░' * (barLength - filledLength);
    final String percentage = (progress * 100).toStringAsFixed(1);

    stdout.write(
      '\r$_cyan$message $_reset[$bar] $percentage% ($current/$total)',
    );

    if (current == total) {
      print(''); // 换行
    }
  }

  /// 清除当前行
  static void clearLine() {
    stdout.write('\r\x1b[K');
  }
}
