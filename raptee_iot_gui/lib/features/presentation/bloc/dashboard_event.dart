import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class DashboardLoadEvent extends DashboardEvent {
  final String bikeId;
  const DashboardLoadEvent(this.bikeId);

  @override
  List<Object> get props => [bikeId];
}

class DashboardLoadMoreEvent extends DashboardEvent {
  const DashboardLoadMoreEvent();
}

class DashboardDeleteBikeEvent extends DashboardEvent {
  final String bikeId;
  const DashboardDeleteBikeEvent(this.bikeId);

  @override
  List<Object> get props => [bikeId];
}

class DashboardDeleteTelemetryEvent extends DashboardEvent {
  final String bikeId;
  const DashboardDeleteTelemetryEvent(this.bikeId);

  @override
  List<Object> get props => [bikeId];
}

class DashboardDeleteBikesEvent extends DashboardEvent {
  final List<String> bikeIds;
  const DashboardDeleteBikesEvent(this.bikeIds);

  @override
  List<Object> get props => [bikeIds];
}

class DashboardDeleteTelemetryBulkEvent extends DashboardEvent {
  final List<String> bikeIds;
  const DashboardDeleteTelemetryBulkEvent(this.bikeIds);

  @override
  List<Object> get props => [bikeIds];
}

class DashboardFetchAllBikesEvent extends DashboardEvent {
  const DashboardFetchAllBikesEvent();
}
