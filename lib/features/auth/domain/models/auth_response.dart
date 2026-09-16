import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required bool success,
    required String message,
    required AuthData? data,
  }) = _AuthResponse;

  const AuthResponse._();

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@freezed
abstract class AuthData with _$AuthData {
  const factory AuthData({
    required String token,
    @JsonKey(name: 'customer') required UserModel user,
  }) = _AuthData;

  const AuthData._();

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
}
