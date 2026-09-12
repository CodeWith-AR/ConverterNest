class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Converter Nest';
  static const String appTagline =
      'Convert anything. Your files, your phone, your privacy.';

  // Nav
  static const String navHome = 'Home';
  static const String navHistory = 'History';
  static const String navSettings = 'Settings';

  // Categories
  static const String catImage = 'Image';
  static const String catAudio = 'Audio';
  static const String catVideo = 'Video';
  static const String catArchive = 'Archive';
  static const String catText = 'Text & Data';
  static const String catPdf = 'PDF Tools';

  // Category subtitles
  static const String catImageSub = 'JPG, PNG, WebP, BMP, GIF, TIFF';
  static const String catAudioSub = 'MP3, AAC, WAV, FLAC, OGG, M4A';
  static const String catVideoSub = 'MP4, MKV, AVI, MOV, WebM, FLV';
  static const String catArchiveSub = 'ZIP, TAR, GZ, TGZ, BZ2, 7Z';
  static const String catTextSub = 'JSON, CSV, XML, YAML, TXT, MD';
  static const String catPdfSub = 'Images to PDF, Merge, Split';

  // Home
  static const String homeGreeting = 'Convert Anything';
  static const String homeSubtitle = 'Free · Offline · Private';
  static const String homeCategory = 'Choose a category';
  static const String homeRecent = 'Recent Conversions';
  static const String homeSeeAll = 'See All';

  // Actions
  static const String actionConvert = 'Convert';
  static const String actionSave = 'Save';
  static const String actionShare = 'Share';
  static const String actionCancel = 'Cancel';
  static const String actionDone = 'Done';
  static const String actionPickFile = 'Pick File';
  static const String actionAddMore = 'Add More';
  static const String actionClear = 'Clear';
  static const String actionDelete = 'Delete';
  static const String actionConfirm = 'Confirm';

  // States
  static const String stateConverting = 'Converting...';
  static const String stateCompleted = 'Conversion Complete!';
  static const String stateFailed = 'Conversion Failed';
  static const String stateNoHistory = 'No conversions yet';
  static const String stateNoHistorySub =
      'Your converted files will appear here';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String settingsWarnings = 'WARNINGS';
  static const String settingsStorage = 'STORAGE';
  static const String settingsPrivacy = 'PRIVACY';
  static const String settingsAbout = 'ABOUT';
  static const String settingsBattery = 'Battery Warning';
  static const String settingsBatterySub = 'Show alert when battery < 20%';
  static const String settingsLargeFile = 'Large File Warning';
  static const String settingsLargeFileSub =
      'Warn for files bigger than threshold';
  static const String settingsThreshold = 'Threshold';
  static const String settingsHistory = 'Conversion History';
  static const String settingsOutputLoc = 'Output Location';
  static const String settingsOutputSub = 'Device Downloads folder';
  static const String settingsPrivacyNote =
      'Your files never leave your device';
  static const String settingsPrivacySub =
      'All conversions happen locally. No uploads. No tracking.';

  // Warnings
  static const String warnBattery =
      'Battery is below 20%. Consider charging before converting large videos.';
  static const String warnLargeFile =
      'This file is large. Conversion may take several minutes and drain battery.';

  // History
  static const String historyTitle = 'History';
  static const String historySearch = 'Search conversions...';
  static const String historyClearAll = 'Clear All';
  static const String historyClearConfirm = 'Clear all conversion history?';
  static const String historyClearSub = 'This action cannot be undone.';

  // Privacy
  static const String privacyNote = 'Your files never leave your device';

  // About
  static const String aboutVersion = 'Version 1.0.0';
  static const String aboutMadeWith = 'Made with ❤️ for everyone. Always free.';
}
