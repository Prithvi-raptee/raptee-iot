class AnalyticsResponse {
  final String bikeId;
  final AnalyticsSummary summary;
  final List<APIStat> apiStats;
  final ConnectivityStats connectivity;
  final List<FailureIncident> failures;
  final List<TimeSeriesPoint> timeSeries;

  AnalyticsResponse({
    required this.bikeId,
    required this.summary,
    required this.apiStats,
    required this.connectivity,
    required this.failures,
    required this.timeSeries,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      bikeId: json['bike_id'] ?? '',
      summary: AnalyticsSummary.fromJson(json['summary'] ?? {}),
      apiStats:
          (json['api_stats'] as List?)
              ?.map((e) => APIStat.fromJson(e))
              .toList() ??
          [],
      connectivity: ConnectivityStats.fromJson(
        json['connectivity_stats'] ?? {},
      ),
      failures:
          (json['failures'] as List?)
              ?.map((e) => FailureIncident.fromJson(e))
              .toList() ??
          [],
      timeSeries:
          (json['time_series'] as List?)
              ?.map((e) => TimeSeriesPoint.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AnalyticsSummary {
  final int totalCalls;
  final double successRate;
  final double networkErrorRate;
  final double serverErrorRate;
  final double clientErrorRate;
  final String startTime;
  final String endTime;

  AnalyticsSummary({
    required this.totalCalls,
    required this.successRate,
    required this.networkErrorRate,
    required this.serverErrorRate,
    required this.clientErrorRate,
    required this.startTime,
    required this.endTime,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalCalls: json['total_calls'] ?? 0,
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      networkErrorRate: (json['network_error_rate'] as num?)?.toDouble() ?? 0.0,
      serverErrorRate: (json['server_error_rate'] as num?)?.toDouble() ?? 0.0,
      clientErrorRate: (json['client_error_rate'] as num?)?.toDouble() ?? 0.0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class APIStat {
  final String apiName;
  final int count;
  final double mean;
  final int max;
  final int min;
  final double errorRate;
  final double p50;
  final double p90;
  final double p95;
  final double p99;

  APIStat({
    required this.apiName,
    required this.count,
    required this.mean,
    required this.max,
    required this.min,
    required this.errorRate,
    required this.p50,
    required this.p90,
    required this.p95,
    required this.p99,
  });

  factory APIStat.fromJson(Map<String, dynamic> json) {
    return APIStat(
      apiName: json['api_name'] ?? '',
      count: json['count'] ?? 0,
      mean: (json['mean'] as num?)?.toDouble() ?? 0.0,
      max: json['max'] ?? 0,
      min: json['min'] ?? 0,
      errorRate: (json['error_rate'] as num?)?.toDouble() ?? 0.0,
      p50: (json['p50'] as num?)?.toDouble() ?? 0.0,
      p90: (json['p90'] as num?)?.toDouble() ?? 0.0,
      p95: (json['p95'] as num?)?.toDouble() ?? 0.0,
      p99: (json['p99'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ConnectivityStats {
  final Map<String, int> stateDistribution;
  final Map<String, double> failureRateByState;
  final Map<String, List<int>> latencyByState;

  ConnectivityStats({
    required this.stateDistribution,
    required this.failureRateByState,
    required this.latencyByState,
  });

  factory ConnectivityStats.fromJson(Map<String, dynamic> json) {
    return ConnectivityStats(
      stateDistribution: Map<String, int>.from(
        json['state_distribution'] ?? {},
      ),
      failureRateByState:
          (json['failure_rate_by_state'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      latencyByState:
          (json['latency_by_state'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as List).map((e) => e as int).toList()),
          ) ??
          {},
    );
  }
}

class FailureIncident {
  final String timestamp;
  final String apiName;
  final int statusCode;
  final int latency;
  final String type;

  FailureIncident({
    required this.timestamp,
    required this.apiName,
    required this.statusCode,
    required this.latency,
    required this.type,
  });

  factory FailureIncident.fromJson(Map<String, dynamic> json) {
    return FailureIncident(
      timestamp: json['timestamp'] ?? '',
      apiName: json['api_name'] ?? '',
      statusCode: json['status_code'] ?? 0,
      latency: json['latency'] ?? 0,
      type: json['type'] ?? '',
    );
  }
}

class TimeSeriesPoint {
  final String timestamp;
  final int latency;
  final String apiName;
  final int status;
  final int signalStrength;
  final String connectionState;

  TimeSeriesPoint({
    required this.timestamp,
    required this.latency,
    required this.apiName,
    required this.status,
    required this.signalStrength,
    required this.connectionState,
  });

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return TimeSeriesPoint(
      timestamp: json['timestamp'] ?? '',
      latency: json['latency'] ?? 0,
      apiName: json['api_name'] ?? '',
      status: json['status'] ?? 0,
      signalStrength: json['signal_strength'] ?? 0,
      connectionState: json['connection_state'] ?? '',
    );
  }
}
