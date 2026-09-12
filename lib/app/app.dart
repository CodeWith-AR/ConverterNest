import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/app_providers.dart';
import 'routes/app_router.dart';
import '../core/theme/theme.dart';
import '../modules/settings/viewmodels/settings_viewmodel.dart';

class ConverterNestApp extends StatelessWidget {
  const ConverterNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders(),
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsVm, _) {
          return MaterialApp.router(
            title: 'Converter Nest',
            theme: buildAppLightTheme(),
            darkTheme: buildAppTheme(),
            themeMode: settingsVm.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
