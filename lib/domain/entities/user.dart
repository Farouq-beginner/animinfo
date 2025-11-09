import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String password;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [id, username, email, password];
}