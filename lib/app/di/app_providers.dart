import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../data/storage/local_store.dart';
import '../../data/storage/history_store.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../modules/home/viewmodels/home_viewmodel.dart';
import '../../modules/history/viewmodels/history_viewmodel.dart';
import '../../modules/settings/viewmodels/settings_viewmodel.dart';
// Module 2 — Image
import '../../modules/image_converter/repositories/image_conversion_repository.dart';
import '../../modules/image_converter/viewmodels/image_converter_viewmodel.dart';
// Module 3 — Audio
import '../../modules/audio_converter/repositories/audio_conversion_repository.dart';
import '../../modules/audio_converter/viewmodels/audio_converter_viewmodel.dart';
// Module 4 — Video
import '../../modules/video_converter/repositories/video_conversion_repository.dart';
import '../../modules/video_converter/viewmodels/video_converter_viewmodel.dart';
// Module 5 — Archive
import '../../modules/archive_manager/repositories/archive_repository.dart';
import '../../modules/archive_manager/viewmodels/archive_viewmodel.dart';
// Module 6 — Text
import '../../modules/text_converter/repositories/text_conversion_repository.dart';
import '../../modules/text_converter/viewmodels/text_converter_viewmodel.dart';
// Module 7 — PDF
import '../../modules/pdf_tools/repositories/pdf_repository.dart';
import '../../modules/pdf_tools/viewmodels/pdf_tools_viewmodel.dart';

List<SingleChildWidget> appProviders() => [
      // Core stores
      Provider<LocalStore>(create: (_) => LocalStore()),
      Provider<HistoryStore>(create: (_) => HistoryStore()),
      Provider<HistoryRepository>(
          create: (ctx) => HistoryRepository(ctx.read())),
      Provider<SettingsRepository>(
          create: (ctx) => SettingsRepository(ctx.read())),

      // Module 01 — Shell
      ChangeNotifierProvider<HomeViewModel>(
          create: (ctx) => HomeViewModel(ctx.read())),
      ChangeNotifierProvider<HistoryViewModel>(
          create: (ctx) => HistoryViewModel(ctx.read())),
      ChangeNotifierProvider<SettingsViewModel>(
        create: (ctx) => SettingsViewModel(ctx.read(), ctx.read()),
      ),

      // Module 02 — Image
      Provider<ImageConversionRepository>(
          create: (_) => ImageConversionRepository()),
      ChangeNotifierProvider<ImageConverterViewModel>(
        create: (ctx) => ImageConverterViewModel(ctx.read(), ctx.read()),
      ),

      // Module 03 — Audio
      Provider<AudioConversionRepository>(
          create: (_) => AudioConversionRepository()),
      ChangeNotifierProvider<AudioConverterViewModel>(
        create: (ctx) => AudioConverterViewModel(ctx.read(), ctx.read()),
      ),

      // Module 04 — Video
      Provider<VideoConversionRepository>(
          create: (_) => VideoConversionRepository()),
      ChangeNotifierProvider<VideoConverterViewModel>(
        create: (ctx) => VideoConverterViewModel(ctx.read(), ctx.read()),
      ),

      // Module 05 — Archive
      Provider<ArchiveRepository>(create: (_) => ArchiveRepository()),
      ChangeNotifierProvider<ArchiveViewModel>(
        create: (ctx) => ArchiveViewModel(ctx.read(), ctx.read()),
      ),

      // Module 06 — Text
      Provider<TextConversionRepository>(
          create: (_) => TextConversionRepository()),
      ChangeNotifierProvider<TextConverterViewModel>(
        create: (ctx) => TextConverterViewModel(ctx.read(), ctx.read()),
      ),

      // Module 07 — PDF
      Provider<PdfRepository>(create: (_) => PdfRepository()),
      ChangeNotifierProvider<PdfToolsViewModel>(
        create: (ctx) => PdfToolsViewModel(ctx.read(), ctx.read()),
      ),
    ];
