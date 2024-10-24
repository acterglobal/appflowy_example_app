// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mention_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MentionState {
  bool get isLoading => throw _privateConstructorUsedError;
  String get mentionId => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String get mentionType =>
      throw _privateConstructorUsedError; // 'user' or 'room'
  bool get isDeleted => throw _privateConstructorUsedError;
  bool get isInTrash => throw _privateConstructorUsedError;

  /// Create a copy of MentionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MentionStateCopyWith<MentionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MentionStateCopyWith<$Res> {
  factory $MentionStateCopyWith(
          MentionState value, $Res Function(MentionState) then) =
      _$MentionStateCopyWithImpl<$Res, MentionState>;
  @useResult
  $Res call(
      {bool isLoading,
      String mentionId,
      String? displayName,
      String mentionType,
      bool isDeleted,
      bool isInTrash});
}

/// @nodoc
class _$MentionStateCopyWithImpl<$Res, $Val extends MentionState>
    implements $MentionStateCopyWith<$Res> {
  _$MentionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MentionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? mentionId = null,
    Object? displayName = freezed,
    Object? mentionType = null,
    Object? isDeleted = null,
    Object? isInTrash = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      mentionId: null == mentionId
          ? _value.mentionId
          : mentionId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      mentionType: null == mentionType
          ? _value.mentionType
          : mentionType // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isInTrash: null == isInTrash
          ? _value.isInTrash
          : isInTrash // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MentionStateImplCopyWith<$Res>
    implements $MentionStateCopyWith<$Res> {
  factory _$$MentionStateImplCopyWith(
          _$MentionStateImpl value, $Res Function(_$MentionStateImpl) then) =
      __$$MentionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String mentionId,
      String? displayName,
      String mentionType,
      bool isDeleted,
      bool isInTrash});
}

/// @nodoc
class __$$MentionStateImplCopyWithImpl<$Res>
    extends _$MentionStateCopyWithImpl<$Res, _$MentionStateImpl>
    implements _$$MentionStateImplCopyWith<$Res> {
  __$$MentionStateImplCopyWithImpl(
      _$MentionStateImpl _value, $Res Function(_$MentionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MentionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? mentionId = null,
    Object? displayName = freezed,
    Object? mentionType = null,
    Object? isDeleted = null,
    Object? isInTrash = null,
  }) {
    return _then(_$MentionStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      mentionId: null == mentionId
          ? _value.mentionId
          : mentionId // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      mentionType: null == mentionType
          ? _value.mentionType
          : mentionType // ignore: cast_nullable_to_non_nullable
              as String,
      isDeleted: null == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      isInTrash: null == isInTrash
          ? _value.isInTrash
          : isInTrash // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MentionStateImpl implements _MentionState {
  const _$MentionStateImpl(
      {required this.isLoading,
      required this.mentionId,
      this.displayName,
      required this.mentionType,
      required this.isDeleted,
      this.isInTrash = false});

  @override
  final bool isLoading;
  @override
  final String mentionId;
  @override
  final String? displayName;
  @override
  final String mentionType;
// 'user' or 'room'
  @override
  final bool isDeleted;
  @override
  @JsonKey()
  final bool isInTrash;

  @override
  String toString() {
    return 'MentionState(isLoading: $isLoading, mentionId: $mentionId, displayName: $displayName, mentionType: $mentionType, isDeleted: $isDeleted, isInTrash: $isInTrash)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MentionStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.mentionId, mentionId) ||
                other.mentionId == mentionId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.mentionType, mentionType) ||
                other.mentionType == mentionType) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.isInTrash, isInTrash) ||
                other.isInTrash == isInTrash));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, mentionId,
      displayName, mentionType, isDeleted, isInTrash);

  /// Create a copy of MentionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MentionStateImplCopyWith<_$MentionStateImpl> get copyWith =>
      __$$MentionStateImplCopyWithImpl<_$MentionStateImpl>(this, _$identity);
}

abstract class _MentionState implements MentionState {
  const factory _MentionState(
      {required final bool isLoading,
      required final String mentionId,
      final String? displayName,
      required final String mentionType,
      required final bool isDeleted,
      final bool isInTrash}) = _$MentionStateImpl;

  @override
  bool get isLoading;
  @override
  String get mentionId;
  @override
  String? get displayName;
  @override
  String get mentionType; // 'user' or 'room'
  @override
  bool get isDeleted;
  @override
  bool get isInTrash;

  /// Create a copy of MentionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MentionStateImplCopyWith<_$MentionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
