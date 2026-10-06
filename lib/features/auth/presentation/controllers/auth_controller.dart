import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState {
  unauthenticated,
  authenticated,
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState.unauthenticated);

  void login() {
    state = AuthState.authenticated;
  }

  void logout() {
    state = AuthState.unauthenticated;
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
