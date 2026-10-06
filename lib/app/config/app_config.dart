import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'environment.dart';

/// Centralized configuration provider for different deployment environments
class AppConfig {
  final Environment environment;
  final String appTitle;
  final String apiBaseUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool enableLogging;
  final bool enableAnalytics;

  const AppConfig({
    required this.environment,
    required this.appTitle,
    required this.apiBaseUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.enableLogging = true,
    this.enableAnalytics = false,
  });

  factory AppConfig.dev() {
    return const AppConfig(
      environment: Environment.dev,
      appTitle: 'Project X (Dev)',
      apiBaseUrl: 'https://dev-api.projectx.com/v1',
      supabaseUrl: 'https://pyjuquwuyijcyadcnjxc.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5anVxdXd1eWlqY3lhZGNuanhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNzI5NzIsImV4cCI6MjEwNjg0ODk3Mn0.dng6kNTBfjPtmwrNHEm8m-pr9rTH-qlFMFHIv9smrLY',
      enableLogging: true,
      enableAnalytics: false,
    );
  }

  factory AppConfig.staging() {
    return const AppConfig(
      environment: Environment.staging,
      appTitle: 'Project X (Staging)',
      apiBaseUrl: 'https://staging-api.projectx.com/v1',
      supabaseUrl: 'https://pyjuquwuyijcyadcnjxc.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5anVxdXd1eWlqY3lhZGNuanhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNzI5NzIsImV4cCI6MjEwNjg0ODk3Mn0.dng6kNTBfjPtmwrNHEm8m-pr9rTH-qlFMFHIv9smrLY',
      enableLogging: true,
      enableAnalytics: true,
    );
  }

  factory AppConfig.prod() {
    return const AppConfig(
      environment: Environment.prod,
      appTitle: 'Project X',
      apiBaseUrl: 'https://api.projectx.com/v1',
      supabaseUrl: 'https://pyjuquwuyijcyadcnjxc.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5anVxdXd1eWlqY3lhZGNuanhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNzI5NzIsImV4cCI6MjEwNjg0ODk3Mn0.dng6kNTBfjPtmwrNHEm8m-pr9rTH-qlFMFHIv9smrLY',
      enableLogging: false,
      enableAnalytics: true,
    );
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden in main()');
});
