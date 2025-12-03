// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telemetry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TelemetryModel _$TelemetryModelFromJson(Map<String, dynamic> json) {
  return _TelemetryModel.fromJson(json);
}

/// @nodoc
mixin _$TelemetryModel {
  String get uuid => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'val_primary')
  int get valPrimary => throw _privateConstructorUsedError;
  dynamic get payload => throw _privateConstructorUsedError;

  /// Serializes this TelemetryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TelemetryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TelemetryModelCopyWith<TelemetryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelemetryModelCopyWith<$Res> {
  factory $TelemetryModelCopyWith(
    TelemetryModel value,
    $Res Function(TelemetryModel) then,
  ) = _$TelemetryModelCopyWithImpl<$Res, TelemetryModel>;
  @useResult
  $Res call({
    String uuid,
    DateTime timestamp,
    String type,
    @JsonKey(name: 'val_primary') int valPrimary,
    dynamic payload,
  });
}

/// @nodoc
class _$TelemetryModelCopyWithImpl<$Res, $Val extends TelemetryModel>
    implements $TelemetryModelCopyWith<$Res> {
  _$TelemetryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TelemetryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? timestamp = null,
    Object? type = null,
    Object? valPrimary = null,
    Object? payload = freezed,
  }) {
    return _then(
      _value.copyWith(
            uuid: null == uuid
                ? _value.uuid
                : uuid // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            valPrimary: null == valPrimary
                ? _value.valPrimary
                : valPrimary // ignore: cast_nullable_to_non_nullable
                      as int,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TelemetryModelImplCopyWith<$Res>
    implements $TelemetryModelCopyWith<$Res> {
  factory _$$TelemetryModelImplCopyWith(
    _$TelemetryModelImpl value,
    $Res Function(_$TelemetryModelImpl) then,
  ) = __$$TelemetryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uuid,
    DateTime timestamp,
    String type,
    @JsonKey(name: 'val_primary') int valPrimary,
    dynamic payload,
  });
}

/// @nodoc
class __$$TelemetryModelImplCopyWithImpl<$Res>
    extends _$TelemetryModelCopyWithImpl<$Res, _$TelemetryModelImpl>
    implements _$$TelemetryModelImplCopyWith<$Res> {
  __$$TelemetryModelImplCopyWithImpl(
    _$TelemetryModelImpl _value,
    $Res Function(_$TelemetryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TelemetryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? timestamp = null,
    Object? type = null,
    Object? valPrimary = null,
    Object? payload = freezed,
  }) {
    return _then(
      _$TelemetryModelImpl(
        uuid: null == uuid
            ? _value.uuid
            : uuid // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        valPrimary: null == valPrimary
            ? _value.valPrimary
            : valPrimary // ignore: cast_nullable_to_non_nullable
                  as int,
        payload: freezed == payload
            ? _value.payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetryModelImpl implements _TelemetryModel {
  const _$TelemetryModelImpl({
    required this.uuid,
    required this.timestamp,
    required this.type,
    @JsonKey(name: 'val_primary') required this.valPrimary,
    required this.payload,
  });

  factory _$TelemetryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetryModelImplFromJson(json);

  @override
  final String uuid;
  @override
  final DateTime timestamp;
  @override
  final String type;
  @override
  @JsonKey(name: 'val_primary')
  final int valPrimary;
  @override
  final dynamic payload;

  @override
  String toString() {
    return 'TelemetryModel(uuid: $uuid, timestamp: $timestamp, type: $type, valPrimary: $valPrimary, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetryModelImpl &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.valPrimary, valPrimary) ||
                other.valPrimary == valPrimary) &&
            const DeepCollectionEquality().equals(other.payload, payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uuid,
    timestamp,
    type,
    valPrimary,
    const DeepCollectionEquality().hash(payload),
  );

  /// Create a copy of TelemetryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TelemetryModelImplCopyWith<_$TelemetryModelImpl> get copyWith =>
      __$$TelemetryModelImplCopyWithImpl<_$TelemetryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TelemetryModelImplToJson(this);
  }
}

abstract class _TelemetryModel implements TelemetryModel {
  const factory _TelemetryModel({
    required final String uuid,
    required final DateTime timestamp,
    required final String type,
    @JsonKey(name: 'val_primary') required final int valPrimary,
    required final dynamic payload,
  }) = _$TelemetryModelImpl;

  factory _TelemetryModel.fromJson(Map<String, dynamic> json) =
      _$TelemetryModelImpl.fromJson;

  @override
  String get uuid;
  @override
  DateTime get timestamp;
  @override
  String get type;
  @override
  @JsonKey(name: 'val_primary')
  int get valPrimary;
  @override
  dynamic get payload;

  /// Create a copy of TelemetryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetryModelImplCopyWith<_$TelemetryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
