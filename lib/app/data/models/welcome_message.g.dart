// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WelcomeMessageImpl _$$WelcomeMessageImplFromJson(Map<String, dynamic> json) =>
    _$WelcomeMessageImpl(
      title: json['title'] as String,
      message: json['message'] as String,
      isVisible: json['isVisible'] as bool? ?? true,
    );

Map<String, dynamic> _$$WelcomeMessageImplToJson(
  _$WelcomeMessageImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'message': instance.message,
  'isVisible': instance.isVisible,
};
