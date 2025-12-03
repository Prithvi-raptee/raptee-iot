import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_model.freezed.dart';
part 'telemetry_model.g.dart';

@freezed
class TelemetryModel with _$TelemetryModel {
  const factory TelemetryModel({
    required String bikeId,
    required double speed,
    required double batteryLevel,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    @Default(false) bool isMoving,
  }) = _TelemetryModel;

  factory TelemetryModel.fromJson(Map<String, dynamic> json) =>
      _$TelemetryModelFromJson(json);
}
