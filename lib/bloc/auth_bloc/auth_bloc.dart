import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/onesignal_service.dart';
import '../../services/firestore_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthEmailVerificationChecked>(_onEmailVerificationChecked);
    on<AuthResendVerificationEmail>(_onResendVerificationEmail);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final error = await AuthService.login(
      email: event.email,
      password: event.password,
    );

    if (error != null) {
      emit(AuthFailure(error));
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      emit(AuthFailure('Login failed. Try again.'));
      return;
    }

    if (!user.emailVerified) {
      emit(AuthEmailNotVerified());
      return;
    }

    // OneSignal player ID save
    await OneSignalService.loginUser(user.uid);
    final playerId = await OneSignalService.getPlayerId();
    if (playerId != null) {
      await FirestoreService.saveOneSignalPlayerId(user.uid, playerId);
    }

    emit(AuthLoginSuccess());
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await AuthService.logout();
    emit(AuthLogoutSuccess());
  }

  Future<void> _onEmailVerificationChecked(
    AuthEmailVerificationChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      emit(AuthEmailVerified());
    } else {
      emit(AuthFailure('Email not verified yet. Check your inbox.'));
    }
  }

  Future<void> _onResendVerificationEmail(
    AuthResendVerificationEmail event,
    Emitter<AuthState> emit,
  ) async {
    await AuthService.resendVerificationEmail();
    emit(AuthResendEmailSuccess());
  }
}
