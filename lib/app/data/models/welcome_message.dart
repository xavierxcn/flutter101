import 'package:freezed_annotation/freezed_annotation.dart';

part 'welcome_message.freezed.dart';
part 'welcome_message.g.dart';

@freezed
class WelcomeMessage with _$WelcomeMessage {
  const factory WelcomeMessage({
    required String title,
    required String message,
    @Default(true) bool isVisible,
  }) = _WelcomeMessage;

  factory WelcomeMessage.fromJson(Map<String, dynamic> json) =>
      _$WelcomeMessageFromJson(json);
}
