import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_model.freezed.dart';
part 'telemetry_model.g.dart';

@freezed
class TelemetryModel with _$TelemetryModel {
  const factory TelemetryModel({
    required String uuid,
    required DateTime timestamp,
    required String type,
    @JsonKey(name: 'val_primary') required int valPrimary,
    required dynamic payload,
  }) = _TelemetryModel;

  factory TelemetryModel.fromJson(Map<String, dynamic> json) =>
      _$TelemetryModelFromJson(json);
}
