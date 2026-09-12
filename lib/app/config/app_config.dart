class AppConfig {
  AppConfig._();

  static const String appName = 'Converter Nest';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  // Android
  static const int minSdkVersion = 21;
  static const int targetSdkVersion = 35;

  // Defaults
  static const int defaultThresholdMb = 200;
  static const int maxRecentJobs = 3;
  static const String defaultOutputDir = 'Downloads';
}
