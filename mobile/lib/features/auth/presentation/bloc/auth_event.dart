import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, fullName, phone, role];
}

class AuthLogoutRequested extends AuthEvent {}
