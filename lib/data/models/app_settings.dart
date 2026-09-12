class AppSettings {
  final String theme; // 'dark' only for now
  final bool showBatteryWarning;
  final bool showLargeFileWarning;
  final int largeFileThresholdMb;

  const AppSettings({
    this.theme = 'dark',
    this.showBatteryWarning = true,
    this.showLargeFileWarning = true,
    this.largeFileThresholdMb = 200,
  });

  AppSettings copyWith({
    String? theme,
    bool? showBatteryWarning,
    bool? showLargeFileWarning,
    int? largeFileThresholdMb,
  }) =>
      AppSettings(
        theme: theme ?? this.theme,
        showBatteryWarning: showBatteryWarning ?? this.showBatteryWarning,
        showLargeFileWarning: showLargeFileWarning ?? this.showLargeFileWarning,
        largeFileThresholdMb: largeFileThresholdMb ?? this.largeFileThresholdMb,
      );
}
