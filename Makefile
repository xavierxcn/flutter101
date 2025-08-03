# Flutter101 项目脚手架 Makefile
# 提供常用命令的快捷方式

.PHONY: help init clean get build run-web run-android run-ios analyze deps gen scripts

# 默认目标：显示帮助
help:
	@echo "🚀 Flutter101 项目脚手架"
	@echo ""
	@echo "可用命令："
	@echo "  help          显示此帮助信息"
	@echo "  init          初始化项目（修改项目名、包名等）"
	@echo "  clean         清理项目"
	@echo "  get           获取依赖"
	@echo "  gen           生成代码"
	@echo "  analyze       分析代码"
	@echo "  build         构建应用"
	@echo "  run-web       运行 Web 应用"
	@echo "  run-android   运行 Android 应用"
	@echo "  run-ios       运行 iOS 应用"
	@echo "  deps          检查依赖"
	@echo "  scripts       打开脚本管理器"
	@echo ""
	@echo "页面生成："
	@echo "  make page name=user_profile    生成用户资料页面"
	@echo "  make model name=user           生成用户模型"
	@echo "  make service name=user_api     生成用户API服务"
	@echo ""
	@echo "翻译管理："
	@echo "  make trans-check               检查翻译完整性"
	@echo "  make trans-add key=hello en='Hello' zh='你好'  添加翻译"

# 项目初始化
init:
	@dart run scripts/project_init.dart

# 清理项目
clean:
	@dart run scripts/build_tools.dart clean

# 获取依赖
get:
	@dart run scripts/build_tools.dart get

# 生成代码
gen:
	@dart run scripts/build_tools.dart generate

# 分析代码
analyze:
	@dart run scripts/build_tools.dart analyze

# 构建应用
build:
	@dart run scripts/build_tools.dart build

# 运行 Web 应用
run-web:
	@dart run scripts/build_tools.dart run web

# 运行 Android 应用
run-android:
	@dart run scripts/build_tools.dart run android

# 运行 iOS 应用
run-ios:
	@dart run scripts/build_tools.dart run ios

# 检查依赖
deps:
	@dart run scripts/build_tools.dart deps

# 脚本管理器
scripts:
	@dart run scripts/script_manager.dart

# 生成页面（需要 name 参数）
page:
ifndef name
	$(error 请指定页面名称: make page name=user_profile)
endif
	@dart run scripts/generate_page.dart $(name)

# 生成模型（需要 name 参数）
model:
ifndef name
	$(error 请指定模型名称: make model name=user)
endif
	@dart run scripts/generate_model.dart $(name)

# 生成服务（需要 name 参数）
service:
ifndef name
	$(error 请指定服务名称: make service name=user_api)
endif
	@dart run scripts/generate_service.dart $(name)

# 检查翻译完整性
trans-check:
	@dart run scripts/translation_manager.dart check

# 添加翻译（需要 key、en、zh 参数）
trans-add:
ifndef key
	$(error 请指定翻译键: make trans-add key=hello en='Hello' zh='你好')
endif
ifndef en
	$(error 请指定英文翻译: make trans-add key=hello en='Hello' zh='你好')
endif
ifndef zh
	$(error 请指定中文翻译: make trans-add key=hello en='Hello' zh='你好')
endif
	@dart run scripts/translation_manager.dart add $(key) $(en) $(zh)

# 完整重建
rebuild: clean get gen analyze
	@echo "✅ 完整重建完成"

# 快速开发设置
setup: get gen
	@echo "✅ 开发环境设置完成"

# 发布准备
release: clean get gen analyze build
	@echo "✅ 发布包构建完成"