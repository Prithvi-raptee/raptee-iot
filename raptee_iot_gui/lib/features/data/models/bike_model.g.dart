// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bike_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BikeModelImpl _$$BikeModelImplFromJson(Map<String, dynamic> json) =>
    _$BikeModelImpl(
      bikeId: json['bike_id'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$BikeModelImplToJson(_$BikeModelImpl instance) =>
    <String, dynamic>{
      'bike_id': instance.bikeId,
      'metadata': instance.metadata,
    };

_$BikeListResponseImpl _$$BikeListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$BikeListResponseImpl(
  nextCursor: json['next_cursor'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => BikeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$BikeListResponseImplToJson(
  _$BikeListResponseImpl instance,
) => <String, dynamic>{
  'next_cursor': instance.nextCursor,
  'data': instance.data,
};
