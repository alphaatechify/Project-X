import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/country.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_verification_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/not_found_screen.dart';
import '../../features/provider/presentation/screens/provider_profile_screen.dart';
import '../../features/services/presentation/screens/service_detail_screen.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.phoneVerification,
    routes: [
      GoRoute(
        path: AppRoutes.phoneVerification,
        name: 'phoneVerification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final country = args['country'] as Country? ?? Country.india;
          final phone = args['phone'] as String? ?? '9876543210';
          final fullNumber = args['fullNumber'] as String? ?? '+91 98765 43210';

          return OtpVerificationScreen(
            country: country,
            phone: phone,
            fullNumber: fullNumber,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        name: 'profileSetup',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final phoneNumber = args['phoneNumber'] as String? ?? '+91 98765 43210';

          return ProfileSetupScreen(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.providerProfile,
        name: 'providerProfile',
        builder: (context, state) => const ProviderProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceDetail,
        name: 'serviceDetail',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final serviceId = args['serviceId'] as String? ?? 'plumber';
          return ServiceDetailScreen(serviceId: serviceId);
        },
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});


