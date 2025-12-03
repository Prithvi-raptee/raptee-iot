// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TelemetryModelImpl _$$TelemetryModelImplFromJson(Map<String, dynamic> json) =>
    _$TelemetryModelImpl(
      uuid: json['uuid'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      valPrimary: (json['val_primary'] as num).toInt(),
      payload: json['payload'],
    );

Map<String, dynamic> _$$TelemetryModelImplToJson(
  _$TelemetryModelImpl instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'timestamp': instance.timestamp.toIso8601String(),
  'type': instance.type,
  'val_primary': instance.valPrimary,
  'payload': instance.payload,
};
