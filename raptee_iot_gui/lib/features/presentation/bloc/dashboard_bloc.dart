import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // In production, inject Repositories here
  DashboardBloc() : super(const DashboardState()) {
    on<DashboardLoadEvent>(_onLoad);
  }

  Future<void> _onLoad(DashboardLoadEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    
    // Simulate API Call
    await Future.delayed(const Duration(seconds: 2));
    
    emit(state.copyWith(
      status: DashboardStatus.success,
      bikeId: "RAPTEE_PRO_001",
      latency: 45
    ));
  }
}