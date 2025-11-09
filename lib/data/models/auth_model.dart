import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel extends User {
  const AuthModel({
    required super.id,
    required super.username,
    required super.email,
    required super.password,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);

  factory AuthModel.fromUser(User user) {
    return AuthModel(
      id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
    );
  }
}