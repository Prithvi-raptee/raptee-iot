import '../../../core/network/api_client.dart';
import '../models/telemetry_response.dart';

abstract class DashboardRemoteDataSource {
  Future<TelemetryResponse> getTelemetry(String bikeId, {String? cursor});
  Future<void> deleteBike(String bikeId);
  Future<void> deleteTelemetry(String bikeId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TelemetryResponse> getTelemetry(String bikeId, {String? cursor}) async {
    final Map<String, dynamic> queryParams = {'bike_id': bikeId};
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get('/telemetry', queryParameters: queryParams);
    print("RAW API RESPONSE: ${response.data}");
    return TelemetryResponse.fromJson(response.data);
  }

  @override
  Future<void> deleteBike(String bikeId) async {
    await apiClient.delete('/provision', queryParameters: {'bike_id': bikeId});
  }

  @override
  Future<void> deleteTelemetry(String bikeId) async {
    await apiClient.delete('/telemetry', queryParameters: {'bike_id': bikeId});
  }
}
