import '../../../core/network/api_client.dart';
import '../models/telemetry_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<TelemetryModel>> getTelemetry(String bikeId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TelemetryModel>> getTelemetry(String bikeId) async {
    final response = await apiClient.get('/bikes/$bikeId/telemetry');
    
    // Assuming response.data is a List
    return (response.data as List)
        .map((e) => TelemetryModel.fromJson(e))
        .toList();
  }
}
