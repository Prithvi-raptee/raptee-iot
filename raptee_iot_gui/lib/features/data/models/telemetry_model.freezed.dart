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
  String get bikeId => throw _privateConstructorUsedError;
  double get speed => throw _privateConstructorUsedError;
  double get batteryLevel => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isMoving => throw _privateConstructorUsedError;

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
    String bikeId,
    double speed,
    double batteryLevel,
    double latitude,
    double longitude,
    DateTime timestamp,
    bool isMoving,
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
    Object? bikeId = null,
    Object? speed = null,
    Object? batteryLevel = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? isMoving = null,
  }) {
    return _then(
      _value.copyWith(
            bikeId: null == bikeId
                ? _value.bikeId
                : bikeId // ignore: cast_nullable_to_non_nullable
                      as String,
            speed: null == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as double,
            batteryLevel: null == batteryLevel
                ? _value.batteryLevel
                : batteryLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isMoving: null == isMoving
                ? _value.isMoving
                : isMoving // ignore: cast_nullable_to_non_nullable
                      as bool,
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
    String bikeId,
    double speed,
    double batteryLevel,
    double latitude,
    double longitude,
    DateTime timestamp,
    bool isMoving,
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
    Object? bikeId = null,
    Object? speed = null,
    Object? batteryLevel = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? isMoving = null,
  }) {
    return _then(
      _$TelemetryModelImpl(
        bikeId: null == bikeId
            ? _value.bikeId
            : bikeId // ignore: cast_nullable_to_non_nullable
                  as String,
        speed: null == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as double,
        batteryLevel: null == batteryLevel
            ? _value.batteryLevel
            : batteryLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isMoving: null == isMoving
            ? _value.isMoving
            : isMoving // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TelemetryModelImpl implements _TelemetryModel {
  const _$TelemetryModelImpl({
    required this.bikeId,
    required this.speed,
    required this.batteryLevel,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isMoving = false,
  });

  factory _$TelemetryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TelemetryModelImplFromJson(json);

  @override
  final String bikeId;
  @override
  final double speed;
  @override
  final double batteryLevel;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isMoving;

  @override
  String toString() {
    return 'TelemetryModel(bikeId: $bikeId, speed: $speed, batteryLevel: $batteryLevel, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, isMoving: $isMoving)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelemetryModelImpl &&
            (identical(other.bikeId, bikeId) || other.bikeId == bikeId) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.batteryLevel, batteryLevel) ||
                other.batteryLevel == batteryLevel) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isMoving, isMoving) ||
                other.isMoving == isMoving));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    bikeId,
    speed,
    batteryLevel,
    latitude,
    longitude,
    timestamp,
    isMoving,
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
    required final String bikeId,
    required final double speed,
    required final double batteryLevel,
    required final double latitude,
    required final double longitude,
    required final DateTime timestamp,
    final bool isMoving,
  }) = _$TelemetryModelImpl;

  factory _TelemetryModel.fromJson(Map<String, dynamic> json) =
      _$TelemetryModelImpl.fromJson;

  @override
  String get bikeId;
  @override
  double get speed;
  @override
  double get batteryLevel;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get timestamp;
  @override
  bool get isMoving;

  /// Create a copy of TelemetryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TelemetryModelImplCopyWith<_$TelemetryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
