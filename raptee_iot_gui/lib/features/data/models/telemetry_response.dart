import 'package:freezed_annotation/freezed_annotation.dart';

part 'telemetry_response.freezed.dart';
part 'telemetry_response.g.dart';

@freezed
class TelemetryResponse with _$TelemetryResponse {
  const factory TelemetryResponse({
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @Default([]) List<String> columns,
    @Default([]) List<List<dynamic>> data,
  }) = _TelemetryResponse;

  factory TelemetryResponse.fromJson(Map<String, dynamic> json) =>
      _$TelemetryResponseFromJson(json);
}
