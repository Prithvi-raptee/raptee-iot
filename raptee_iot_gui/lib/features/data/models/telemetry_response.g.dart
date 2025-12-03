// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TelemetryResponseImpl _$$TelemetryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$TelemetryResponseImpl(
  nextCursor: json['next_cursor'] as String?,
  columns:
      (json['columns'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => e as List<dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$TelemetryResponseImplToJson(
  _$TelemetryResponseImpl instance,
) => <String, dynamic>{
  'next_cursor': instance.nextCursor,
  'columns': instance.columns,
  'data': instance.data,
};
