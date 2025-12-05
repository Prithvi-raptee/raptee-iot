import 'dart:math';

class ChartUtils {
  /// Downsamples a list of data points to a target count using a simple averaging method.
  /// This is useful for rendering large datasets on charts without performance loss.
  ///
  /// [data] is the list of numerical values.
  /// [targetCount] is the desired number of points.
  static List<double> downsampleData(List<double> data, int targetCount) {
    if (data.length <= targetCount) {
      return data;
    }

    final List<double> sampled = [];
    final int blockSize = (data.length / targetCount).ceil();

    for (int i = 0; i < data.length; i += blockSize) {
      double sum = 0;
      int count = 0;
      for (int j = 0; j < blockSize && (i + j) < data.length; j++) {
        sum += data[i + j];
        count++;
      }
      sampled.add(sum / count);
    }

    return sampled;
  }

  /// Downsamples a list of time-series data (Time, Value) pairs.
  /// Assumes [data] is sorted by time.
  static List<MapEntry<DateTime, double>> downsampleTimeSeries(
    List<MapEntry<DateTime, double>> data,
    int targetCount,
  ) {
    if (data.length <= targetCount) {
      return data;
    }

    final List<MapEntry<DateTime, double>> sampled = [];
    final int blockSize = (data.length / targetCount).ceil();

    for (int i = 0; i < data.length; i += blockSize) {
      double sumValue = 0;
      int count = 0;
      int midPointIndex = i + (blockSize ~/ 2);
      if (midPointIndex >= data.length) midPointIndex = data.length - 1;

      // Use the timestamp of the middle point in the bucket
      DateTime timestamp = data[min(midPointIndex, data.length - 1)].key;

      for (int j = 0; j < blockSize && (i + j) < data.length; j++) {
        sumValue += data[i + j].value;
        count++;
      }
      sampled.add(MapEntry(timestamp, sumValue / count));
    }

    return sampled;
  }
}
