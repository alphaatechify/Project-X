import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'config/environment.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class ProjectXApp extends ConsumerWidget {
  const ProjectXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: config.appTitle,
      debugShowCheckedModeBanner: config.environment.isDev,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
