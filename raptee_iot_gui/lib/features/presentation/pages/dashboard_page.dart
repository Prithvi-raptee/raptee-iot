import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_typography.dart';
import '../../data/models/bike_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection
    final apiClient = ApiClient();
    final dataSource = DashboardRemoteDataSourceImpl(apiClient: apiClient);
    final repository = DashboardRepository(remoteDataSource: dataSource);

    return BlocProvider(
      create: (context) => DashboardBloc(repository: repository)
        ..add(const DashboardFetchAllBikesEvent()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fleet Overview"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardFetchAllBikesEvent());
            },
          )
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DashboardStatus.failure) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          if (state.bikes.isEmpty) {
            return const Center(child: Text("No bikes found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.bikes.length,
            itemBuilder: (context, index) {
              final bike = state.bikes[index];
              return _buildBikeCard(context, bike);
            },
          );
        },
      ),
    );
  }

  Widget _buildBikeCard(BuildContext context, BikeModel bike) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.motorcycle),
        ),
        title: Text(bike.bikeId, style: AppTypography.h3),
        subtitle: Text("Model: ${bike.metadata['model'] ?? 'Unknown'} | Color: ${bike.metadata['color'] ?? 'Unknown'}"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.goNamed('details', pathParameters: {'bikeId': bike.bikeId});
        },
      ),
    );
  }
}