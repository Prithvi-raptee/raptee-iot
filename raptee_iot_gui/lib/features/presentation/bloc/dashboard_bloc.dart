import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(const DashboardState()) {
    on<DashboardLoadEvent>(_onLoad);
    on<DashboardLoadMoreEvent>(_onLoadMore);
    on<DashboardDeleteBikeEvent>(_onDeleteBike);
    on<DashboardDeleteTelemetryEvent>(_onDeleteTelemetry);
    on<DashboardDeleteBikesEvent>(_onDeleteBikes);
    on<DashboardDeleteTelemetryBulkEvent>(_onDeleteTelemetryBulk);
    on<DashboardFetchAllBikesEvent>(_onFetchAllBikes);
  }

  Future<void> _onLoad(
    DashboardLoadEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, bikeId: event.bikeId));
    try {
      // Fetch initial data
      final telemetry = await repository.getBikeTelemetry(event.bikeId);
      final analytics = await repository.getBikeAnalytics(event.bikeId);

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          telemetry: telemetry,
          analytics: analytics,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    DashboardLoadMoreEvent event,
    Emitter<DashboardState> emit,
  ) async {
    // Implement if repository supports cursor return
  }

  Future<void> _onDeleteBike(
    DashboardDeleteBikeEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: DeleteStatus.deleting));
    try {
      await repository.deleteBike(event.bikeId);
      add(const DashboardFetchAllBikesEvent());
      emit(
        state.copyWith(
          deleteStatus: DeleteStatus.success,
          telemetry: [],
          status: DashboardStatus.initial,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          deleteStatus: DeleteStatus.failure,
          errorMessage: "Failed to delete bike: $e",
        ),
      );
    }
  }

  Future<void> _onDeleteTelemetry(
    DashboardDeleteTelemetryEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: DeleteStatus.deleting));
    try {
      await repository.deleteTelemetry(event.bikeId);
      add(DashboardLoadEvent(event.bikeId)); // Reload
      emit(state.copyWith(deleteStatus: DeleteStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          deleteStatus: DeleteStatus.failure,
          errorMessage: "Failed to delete telemetry: $e",
        ),
      );
    }
  }

  Future<void> _onFetchAllBikes(
    DashboardFetchAllBikesEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final bikes = await repository.getBikes();
      emit(state.copyWith(status: DashboardStatus.success, bikes: bikes));
    } catch (e) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteBikes(
    DashboardDeleteBikesEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: DeleteStatus.deleting));
    try {
      await repository.deleteBikes(event.bikeIds);
      add(const DashboardFetchAllBikesEvent()); // Reload list
      emit(state.copyWith(deleteStatus: DeleteStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          deleteStatus: DeleteStatus.failure,
          errorMessage: "Failed to delete bikes: $e",
        ),
      );
    }
  }

  Future<void> _onDeleteTelemetryBulk(
    DashboardDeleteTelemetryBulkEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: DeleteStatus.deleting));
    try {
      await repository.deleteTelemetryBulk(event.bikeIds);
      // No need to reload list as bikes are still there, but maybe show success message
      emit(state.copyWith(deleteStatus: DeleteStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          deleteStatus: DeleteStatus.failure,
          errorMessage: "Failed to delete telemetry: $e",
        ),
      );
    }
  }
}
