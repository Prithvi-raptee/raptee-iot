import 'dart:convert';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/telemetry_model.dart';
import '../models/bike_model.dart';

class DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepository({required this.remoteDataSource});

  Future<List<TelemetryModel>> getBikeTelemetry(String bikeId, {String? cursor}) async {
    try {
      final response = await remoteDataSource.getTelemetry(bikeId, cursor: cursor);
      
      // Map compact data to TelemetryModel
      return response.data.map((row) {
        // columns: ["uuid", "timestamp", "type", "val_primary", "payload"]
        // row: ["<uuid>", "<timestamp>", "<type>", <val_primary>, "<payload_json_string>"]
        
        // Ensure row has enough elements
        if (row.length < 5) return null;

        try {
          return TelemetryModel(
            uuid: row[0] as String,
            timestamp: DateTime.parse(row[1] as String),
            type: row[2] as String,
            valPrimary: (row[3] as num?)?.toInt() ?? 0,
            payload: row[4], // Assign raw payload (List or Map)
          );
        } catch (e) {
          print("Error parsing row: $row");
          print("Error details: $e");
          return null;
        }
      }).whereType<TelemetryModel>().toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BikeModel>> getBikes({String? cursor, int limit = 50}) async {
    try {
      final response = await remoteDataSource.getBikes(cursor: cursor, limit: limit);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBike(String bikeId) async {
    await remoteDataSource.deleteBike(bikeId);
  }

  Future<void> deleteBikes(List<String> bikeIds) async {
    await remoteDataSource.deleteBikes(bikeIds);
  }

  Future<void> deleteTelemetry(String bikeId) async {
    await remoteDataSource.deleteTelemetry(bikeId);
  }

  Future<void> deleteTelemetryBulk(List<String> bikeIds) async {
    await remoteDataSource.deleteTelemetryBulk(bikeIds);
  }
}
