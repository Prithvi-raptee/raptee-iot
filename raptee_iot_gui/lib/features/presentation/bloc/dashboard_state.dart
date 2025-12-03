import 'package:equatable/equatable.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final String bikeId;
  final int latency;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.bikeId = '--',
    this.latency = 0,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    String? bikeId,
    int? latency,
  }) {
    return DashboardState(
      status: status ?? this.status,
      bikeId: bikeId ?? this.bikeId,
      latency: latency ?? this.latency,
    );
  }

  @override
  List<Object> get props => [status, bikeId, latency];
}