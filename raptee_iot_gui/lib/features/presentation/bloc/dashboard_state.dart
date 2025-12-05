import 'package:equatable/equatable.dart';
import '../../data/models/telemetry_model.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/bike_model.dart';

enum DashboardStatus { initial, loading, success, failure }
enum DeleteStatus { initial, deleting, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DeleteStatus deleteStatus;
  final String bikeId;
  final List<TelemetryModel> telemetry;
  final AnalyticsResponse? analytics;
  final List<BikeModel> bikes;
  final String? nextCursor;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.deleteStatus = DeleteStatus.initial,
    this.bikeId = '',
    this.telemetry = const [],
    this.analytics,
    this.bikes = const [],
    this.nextCursor,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DeleteStatus? deleteStatus,
    String? bikeId,
    List<TelemetryModel>? telemetry,
    AnalyticsResponse? analytics,
    List<BikeModel>? bikes,
    String? nextCursor,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      bikeId: bikeId ?? this.bikeId,
      telemetry: telemetry ?? this.telemetry,
      analytics: analytics ?? this.analytics,
      bikes: bikes ?? this.bikes,
      nextCursor: nextCursor ?? this.nextCursor,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, deleteStatus, bikeId, telemetry, analytics, bikes, nextCursor, errorMessage];
}