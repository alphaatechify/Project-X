import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Initializing application foundation...');

  final config = AppConfig.dev();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
    AppLogger.info('Supabase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize Supabase', e, stackTrace);
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ProjectXApp(),
    ),
  );
}
