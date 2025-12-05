// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bike_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BikeModel _$BikeModelFromJson(Map<String, dynamic> json) {
  return _BikeModel.fromJson(json);
}

/// @nodoc
mixin _$BikeModel {
  @JsonKey(name: 'bike_id')
  String get bikeId => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_seen_at')
  DateTime? get lastSeenAt => throw _privateConstructorUsedError;

  /// Serializes this BikeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BikeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BikeModelCopyWith<BikeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BikeModelCopyWith<$Res> {
  factory $BikeModelCopyWith(BikeModel value, $Res Function(BikeModel) then) =
      _$BikeModelCopyWithImpl<$Res, BikeModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'bike_id') String bikeId,
    Map<String, dynamic> metadata,
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
  });
}

/// @nodoc
class _$BikeModelCopyWithImpl<$Res, $Val extends BikeModel>
    implements $BikeModelCopyWith<$Res> {
  _$BikeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BikeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bikeId = null,
    Object? metadata = null,
    Object? lastSeenAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            bikeId: null == bikeId
                ? _value.bikeId
                : bikeId // ignore: cast_nullable_to_non_nullable
                      as String,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            lastSeenAt: freezed == lastSeenAt
                ? _value.lastSeenAt
                : lastSeenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BikeModelImplCopyWith<$Res>
    implements $BikeModelCopyWith<$Res> {
  factory _$$BikeModelImplCopyWith(
    _$BikeModelImpl value,
    $Res Function(_$BikeModelImpl) then,
  ) = __$$BikeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'bike_id') String bikeId,
    Map<String, dynamic> metadata,
    @JsonKey(name: 'last_seen_at') DateTime? lastSeenAt,
  });
}

/// @nodoc
class __$$BikeModelImplCopyWithImpl<$Res>
    extends _$BikeModelCopyWithImpl<$Res, _$BikeModelImpl>
    implements _$$BikeModelImplCopyWith<$Res> {
  __$$BikeModelImplCopyWithImpl(
    _$BikeModelImpl _value,
    $Res Function(_$BikeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BikeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bikeId = null,
    Object? metadata = null,
    Object? lastSeenAt = freezed,
  }) {
    return _then(
      _$BikeModelImpl(
        bikeId: null == bikeId
            ? _value.bikeId
            : bikeId // ignore: cast_nullable_to_non_nullable
                  as String,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        lastSeenAt: freezed == lastSeenAt
            ? _value.lastSeenAt
            : lastSeenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BikeModelImpl implements _BikeModel {
  const _$BikeModelImpl({
    @JsonKey(name: 'bike_id') required this.bikeId,
    required final Map<String, dynamic> metadata,
    @JsonKey(name: 'last_seen_at') this.lastSeenAt,
  }) : _metadata = metadata;

  factory _$BikeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BikeModelImplFromJson(json);

  @override
  @JsonKey(name: 'bike_id')
  final String bikeId;
  final Map<String, dynamic> _metadata;
  @override
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @JsonKey(name: 'last_seen_at')
  final DateTime? lastSeenAt;

  @override
  String toString() {
    return 'BikeModel(bikeId: $bikeId, metadata: $metadata, lastSeenAt: $lastSeenAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BikeModelImpl &&
            (identical(other.bikeId, bikeId) || other.bikeId == bikeId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.lastSeenAt, lastSeenAt) ||
                other.lastSeenAt == lastSeenAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    bikeId,
    const DeepCollectionEquality().hash(_metadata),
    lastSeenAt,
  );

  /// Create a copy of BikeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BikeModelImplCopyWith<_$BikeModelImpl> get copyWith =>
      __$$BikeModelImplCopyWithImpl<_$BikeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BikeModelImplToJson(this);
  }
}

abstract class _BikeModel implements BikeModel {
  const factory _BikeModel({
    @JsonKey(name: 'bike_id') required final String bikeId,
    required final Map<String, dynamic> metadata,
    @JsonKey(name: 'last_seen_at') final DateTime? lastSeenAt,
  }) = _$BikeModelImpl;

  factory _BikeModel.fromJson(Map<String, dynamic> json) =
      _$BikeModelImpl.fromJson;

  @override
  @JsonKey(name: 'bike_id')
  String get bikeId;
  @override
  Map<String, dynamic> get metadata;
  @override
  @JsonKey(name: 'last_seen_at')
  DateTime? get lastSeenAt;

  /// Create a copy of BikeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BikeModelImplCopyWith<_$BikeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BikeListResponse _$BikeListResponseFromJson(Map<String, dynamic> json) {
  return _BikeListResponse.fromJson(json);
}

/// @nodoc
mixin _$BikeListResponse {
  @JsonKey(name: 'next_cursor')
  String get nextCursor => throw _privateConstructorUsedError;
  List<BikeModel> get data => throw _privateConstructorUsedError;

  /// Serializes this BikeListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BikeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BikeListResponseCopyWith<BikeListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BikeListResponseCopyWith<$Res> {
  factory $BikeListResponseCopyWith(
    BikeListResponse value,
    $Res Function(BikeListResponse) then,
  ) = _$BikeListResponseCopyWithImpl<$Res, BikeListResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'next_cursor') String nextCursor,
    List<BikeModel> data,
  });
}

/// @nodoc
class _$BikeListResponseCopyWithImpl<$Res, $Val extends BikeListResponse>
    implements $BikeListResponseCopyWith<$Res> {
  _$BikeListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BikeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nextCursor = null, Object? data = null}) {
    return _then(
      _value.copyWith(
            nextCursor: null == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<BikeModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BikeListResponseImplCopyWith<$Res>
    implements $BikeListResponseCopyWith<$Res> {
  factory _$$BikeListResponseImplCopyWith(
    _$BikeListResponseImpl value,
    $Res Function(_$BikeListResponseImpl) then,
  ) = __$$BikeListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'next_cursor') String nextCursor,
    List<BikeModel> data,
  });
}

/// @nodoc
class __$$BikeListResponseImplCopyWithImpl<$Res>
    extends _$BikeListResponseCopyWithImpl<$Res, _$BikeListResponseImpl>
    implements _$$BikeListResponseImplCopyWith<$Res> {
  __$$BikeListResponseImplCopyWithImpl(
    _$BikeListResponseImpl _value,
    $Res Function(_$BikeListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BikeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? nextCursor = null, Object? data = null}) {
    return _then(
      _$BikeListResponseImpl(
        nextCursor: null == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<BikeModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BikeListResponseImpl implements _BikeListResponse {
  const _$BikeListResponseImpl({
    @JsonKey(name: 'next_cursor') required this.nextCursor,
    required final List<BikeModel> data,
  }) : _data = data;

  factory _$BikeListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BikeListResponseImplFromJson(json);

  @override
  @JsonKey(name: 'next_cursor')
  final String nextCursor;
  final List<BikeModel> _data;
  @override
  List<BikeModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'BikeListResponse(nextCursor: $nextCursor, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BikeListResponseImpl &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    nextCursor,
    const DeepCollectionEquality().hash(_data),
  );

  /// Create a copy of BikeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BikeListResponseImplCopyWith<_$BikeListResponseImpl> get copyWith =>
      __$$BikeListResponseImplCopyWithImpl<_$BikeListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BikeListResponseImplToJson(this);
  }
}

abstract class _BikeListResponse implements BikeListResponse {
  const factory _BikeListResponse({
    @JsonKey(name: 'next_cursor') required final String nextCursor,
    required final List<BikeModel> data,
  }) = _$BikeListResponseImpl;

  factory _BikeListResponse.fromJson(Map<String, dynamic> json) =
      _$BikeListResponseImpl.fromJson;

  @override
  @JsonKey(name: 'next_cursor')
  String get nextCursor;
  @override
  List<BikeModel> get data;

  /// Create a copy of BikeListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BikeListResponseImplCopyWith<_$BikeListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
