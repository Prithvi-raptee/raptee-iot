import '../datasources/dashboard_remote_datasource.dart';
import '../models/telemetry_model.dart';

class DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepository({required this.remoteDataSource});

  Future<List<TelemetryModel>> getBikeTelemetry(String bikeId) async {
    try {
      return await remoteDataSource.getTelemetry(bikeId);
    } catch (e) {
      // Handle exceptions or map to Failures here
      rethrow;
    }
  }
}
