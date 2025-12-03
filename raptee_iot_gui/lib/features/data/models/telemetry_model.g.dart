// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TelemetryModelImpl _$$TelemetryModelImplFromJson(Map<String, dynamic> json) =>
    _$TelemetryModelImpl(
      bikeId: json['bikeId'] as String,
      speed: (json['speed'] as num).toDouble(),
      batteryLevel: (json['batteryLevel'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isMoving: json['isMoving'] as bool? ?? false,
    );

Map<String, dynamic> _$$TelemetryModelImplToJson(
  _$TelemetryModelImpl instance,
) => <String, dynamic>{
  'bikeId': instance.bikeId,
  'speed': instance.speed,
  'batteryLevel': instance.batteryLevel,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timestamp': instance.timestamp.toIso8601String(),
  'isMoving': instance.isMoving,
};
