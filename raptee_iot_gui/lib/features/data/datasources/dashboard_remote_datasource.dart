import '../../../core/network/api_client.dart';
import '../models/telemetry_response.dart';
import '../models/analytics_model.dart';
import '../models/bike_model.dart';

abstract class DashboardRemoteDataSource {
  Future<TelemetryResponse> getTelemetry(String bikeId, {String? cursor});
  Future<AnalyticsResponse> getAnalytics(String bikeId);
  Future<BikeListResponse> getBikes({String? cursor, int limit = 50});
  Future<void> deleteBike(String bikeId);
  Future<void> deleteBikes(List<String> bikeIds);
  Future<void> deleteTelemetry(String bikeId);
  Future<void> deleteTelemetryBulk(List<String> bikeIds);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TelemetryResponse> getTelemetry(
    String bikeId, {
    String? cursor,
  }) async {
    final Map<String, dynamic> queryParams = {'bike_id': bikeId};
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/telemetry',
      queryParameters: queryParams,
    );
    return TelemetryResponse.fromJson(response.data);
  }

  @override
  Future<AnalyticsResponse> getAnalytics(String bikeId) async {
    final response = await apiClient.get(
      '/analytics',
      queryParameters: {'bike_id': bikeId},
    );
    return AnalyticsResponse.fromJson(response.data);
  }

  @override
  Future<BikeListResponse> getBikes({String? cursor, int limit = 50}) async {
    final Map<String, dynamic> queryParams = {'limit': limit};
    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await apiClient.get(
      '/bikes',
      queryParameters: queryParams,
    );
    return BikeListResponse.fromJson(response.data);
  }

  @override
  Future<void> deleteBike(String bikeId) async {
    await apiClient.delete('/provision', queryParameters: {'bike_id': bikeId});
  }

  @override
  Future<void> deleteBikes(List<String> bikeIds) async {
    await apiClient.delete('/bikes', data: {'bike_ids': bikeIds});
  }

  @override
  Future<void> deleteTelemetry(String bikeId) async {
    await apiClient.delete('/telemetry', queryParameters: {'bike_id': bikeId});
  }

  @override
  Future<void> deleteTelemetryBulk(List<String> bikeIds) async {
    await apiClient.delete('/telemetry', data: {'bike_ids': bikeIds});
  }
}
