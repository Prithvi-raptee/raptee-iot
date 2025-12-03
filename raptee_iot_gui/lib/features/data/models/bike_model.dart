import 'package:freezed_annotation/freezed_annotation.dart';

part 'bike_model.freezed.dart';
part 'bike_model.g.dart';

@freezed
class BikeModel with _$BikeModel {
  const factory BikeModel({
    @JsonKey(name: 'bike_id') required String bikeId,
    required Map<String, dynamic> metadata,
  }) = _BikeModel;

  factory BikeModel.fromJson(Map<String, dynamic> json) =>
      _$BikeModelFromJson(json);
}

@freezed
class BikeListResponse with _$BikeListResponse {
  const factory BikeListResponse({
    @JsonKey(name: 'next_cursor') required String nextCursor,
    required List<BikeModel> data,
  }) = _BikeListResponse;

  factory BikeListResponse.fromJson(Map<String, dynamic> json) =>
      _$BikeListResponseFromJson(json);
}
