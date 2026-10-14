import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:project_x/app/app.dart';
import 'package:project_x/app/config/app_config.dart';
import 'package:project_x/core/storage/local_storage.dart';
import 'package:project_x/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App loads HomeScreen by default', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev()),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const ProjectXApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Indiranagar'), findsWidgets);
  });

  testWidgets('PhoneVerificationScreen displays correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev()),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MaterialApp(
          home: PhoneVerificationScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Phone Verification'), findsOneWidget);
    expect(find.textContaining('Enter Phone number for'), findsOneWidget);
    expect(find.text('Auto-detect'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
