// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['id'] as num).toInt(),
  fullName: json['name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phone_number'] as String?,
  avatarUrl: json['profile_picture'] as String?,
  pointBalance: (json['point_balance'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
  isEmailVerified: json['is_email_verified'] as bool? ?? false,
  googleId: json['google_id'] as String?,
  isSystemAdmin: json['is_system_admin'] as bool? ?? false,
  emailVerifiedAt: json['email_verified_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.fullName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'profile_picture': instance.avatarUrl,
      'point_balance': instance.pointBalance,
      'is_active': instance.isActive,
      'is_email_verified': instance.isEmailVerified,
      'google_id': instance.googleId,
      'is_system_admin': instance.isSystemAdmin,
      'email_verified_at': instance.emailVerifiedAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
