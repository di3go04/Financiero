import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  final AuthChangeEvent event;
  final Session? session;
  AuthStatusChanged(this.event, this.session);
  
  @override
  List<Object?> get props => [event, session];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested(this.email, this.password);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  AuthSignUpRequested(this.email, this.password, this.fullName);
}

class AuthSignOutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    _supabase.auth.onAuthStateChange.listen((data) {
      add(AuthStatusChanged(data.event, data.session));
    });

    on<AuthStatusChanged>((event, emit) {
      if (event.session != null) {
        emit(AuthAuthenticated(event.session!.user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _supabase.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _supabase.auth.signUp(
          email: event.email,
          password: event.password,
          data: {'full_name': event.fullName},
        );
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      await _supabase.auth.signOut();
    });
  }
}


