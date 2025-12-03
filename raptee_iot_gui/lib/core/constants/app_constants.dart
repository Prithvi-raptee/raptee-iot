class AppConstants {
  // App Config
  static const String appName = "Raptee IoT";
  
  // API Config
  static const String apiBaseUrl = "https://n4gzvnxn5h.ap-south-1.awsapprunner.com/api/v1";
  static const int connectTimeout = 15000;
  static const int refreshRateMs = 5000;

  // UI Config
  static const double sidebarWidth = 250.0;
  static const double defaultPadding = 16.0;
  static const double cardRadius = 8.0;
}

// Strict Types for your data
enum BikeStatus { online, offline, warning }
enum LogType { apiLatency, gpsJump, signal }