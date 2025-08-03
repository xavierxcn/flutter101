// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'welcome_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WelcomeMessage _$WelcomeMessageFromJson(Map<String, dynamic> json) {
  return _WelcomeMessage.fromJson(json);
}

/// @nodoc
mixin _$WelcomeMessage {
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get isVisible => throw _privateConstructorUsedError;

  /// Serializes this WelcomeMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WelcomeMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WelcomeMessageCopyWith<WelcomeMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WelcomeMessageCopyWith<$Res> {
  factory $WelcomeMessageCopyWith(
    WelcomeMessage value,
    $Res Function(WelcomeMessage) then,
  ) = _$WelcomeMessageCopyWithImpl<$Res, WelcomeMessage>;
  @useResult
  $Res call({String title, String message, bool isVisible});
}

/// @nodoc
class _$WelcomeMessageCopyWithImpl<$Res, $Val extends WelcomeMessage>
    implements $WelcomeMessageCopyWith<$Res> {
  _$WelcomeMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WelcomeMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? message = null,
    Object? isVisible = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            isVisible: null == isVisible
                ? _value.isVisible
                : isVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WelcomeMessageImplCopyWith<$Res>
    implements $WelcomeMessageCopyWith<$Res> {
  factory _$$WelcomeMessageImplCopyWith(
    _$WelcomeMessageImpl value,
    $Res Function(_$WelcomeMessageImpl) then,
  ) = __$$WelcomeMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String message, bool isVisible});
}

/// @nodoc
class __$$WelcomeMessageImplCopyWithImpl<$Res>
    extends _$WelcomeMessageCopyWithImpl<$Res, _$WelcomeMessageImpl>
    implements _$$WelcomeMessageImplCopyWith<$Res> {
  __$$WelcomeMessageImplCopyWithImpl(
    _$WelcomeMessageImpl _value,
    $Res Function(_$WelcomeMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WelcomeMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? message = null,
    Object? isVisible = null,
  }) {
    return _then(
      _$WelcomeMessageImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        isVisible: null == isVisible
            ? _value.isVisible
            : isVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WelcomeMessageImpl implements _WelcomeMessage {
  const _$WelcomeMessageImpl({
    required this.title,
    required this.message,
    this.isVisible = true,
  });

  factory _$WelcomeMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$WelcomeMessageImplFromJson(json);

  @override
  final String title;
  @override
  final String message;
  @override
  @JsonKey()
  final bool isVisible;

  @override
  String toString() {
    return 'WelcomeMessage(title: $title, message: $message, isVisible: $isVisible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WelcomeMessageImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, message, isVisible);

  /// Create a copy of WelcomeMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WelcomeMessageImplCopyWith<_$WelcomeMessageImpl> get copyWith =>
      __$$WelcomeMessageImplCopyWithImpl<_$WelcomeMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WelcomeMessageImplToJson(this);
  }
}

abstract class _WelcomeMessage implements WelcomeMessage {
  const factory _WelcomeMessage({
    required final String title,
    required final String message,
    final bool isVisible,
  }) = _$WelcomeMessageImpl;

  factory _WelcomeMessage.fromJson(Map<String, dynamic> json) =
      _$WelcomeMessageImpl.fromJson;

  @override
  String get title;
  @override
  String get message;
  @override
  bool get isVisible;

  /// Create a copy of WelcomeMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WelcomeMessageImplCopyWith<_$WelcomeMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
