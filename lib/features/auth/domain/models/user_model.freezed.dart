// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 int get id;@JsonKey(name: 'name') String get fullName; String get email;@JsonKey(name: 'phone_number') String? get phoneNumber;@JsonKey(name: 'profile_picture') String? get avatarUrl;@JsonKey(name: 'point_balance') int get pointBalance;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_email_verified') bool get isEmailVerified;@JsonKey(name: 'google_id') String? get googleId;@JsonKey(name: 'is_system_admin') bool get isSystemAdmin;@JsonKey(name: 'email_verified_at') String? get emailVerifiedAt;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.pointBalance, pointBalance) || other.pointBalance == pointBalance)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.googleId, googleId) || other.googleId == googleId)&&(identical(other.isSystemAdmin, isSystemAdmin) || other.isSystemAdmin == isSystemAdmin)&&(identical(other.emailVerifiedAt, emailVerifiedAt) || other.emailVerifiedAt == emailVerifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phoneNumber,avatarUrl,pointBalance,isActive,isEmailVerified,googleId,isSystemAdmin,emailVerifiedAt,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, pointBalance: $pointBalance, isActive: $isActive, isEmailVerified: $isEmailVerified, googleId: $googleId, isSystemAdmin: $isSystemAdmin, emailVerifiedAt: $emailVerifiedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'name') String fullName, String email,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'profile_picture') String? avatarUrl,@JsonKey(name: 'point_balance') int pointBalance,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_email_verified') bool isEmailVerified,@JsonKey(name: 'google_id') String? googleId,@JsonKey(name: 'is_system_admin') bool isSystemAdmin,@JsonKey(name: 'email_verified_at') String? emailVerifiedAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phoneNumber = freezed,Object? avatarUrl = freezed,Object? pointBalance = null,Object? isActive = null,Object? isEmailVerified = null,Object? googleId = freezed,Object? isSystemAdmin = null,Object? emailVerifiedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,pointBalance: null == pointBalance ? _self.pointBalance : pointBalance // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,googleId: freezed == googleId ? _self.googleId : googleId // ignore: cast_nullable_to_non_nullable
as String?,isSystemAdmin: null == isSystemAdmin ? _self.isSystemAdmin : isSystemAdmin // ignore: cast_nullable_to_non_nullable
as bool,emailVerifiedAt: freezed == emailVerifiedAt ? _self.emailVerifiedAt : emailVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'name')  String fullName,  String email, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'profile_picture')  String? avatarUrl, @JsonKey(name: 'point_balance')  int pointBalance, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_email_verified')  bool isEmailVerified, @JsonKey(name: 'google_id')  String? googleId, @JsonKey(name: 'is_system_admin')  bool isSystemAdmin, @JsonKey(name: 'email_verified_at')  String? emailVerifiedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phoneNumber,_that.avatarUrl,_that.pointBalance,_that.isActive,_that.isEmailVerified,_that.googleId,_that.isSystemAdmin,_that.emailVerifiedAt,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'name')  String fullName,  String email, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'profile_picture')  String? avatarUrl, @JsonKey(name: 'point_balance')  int pointBalance, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_email_verified')  bool isEmailVerified, @JsonKey(name: 'google_id')  String? googleId, @JsonKey(name: 'is_system_admin')  bool isSystemAdmin, @JsonKey(name: 'email_verified_at')  String? emailVerifiedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.fullName,_that.email,_that.phoneNumber,_that.avatarUrl,_that.pointBalance,_that.isActive,_that.isEmailVerified,_that.googleId,_that.isSystemAdmin,_that.emailVerifiedAt,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'name')  String fullName,  String email, @JsonKey(name: 'phone_number')  String? phoneNumber, @JsonKey(name: 'profile_picture')  String? avatarUrl, @JsonKey(name: 'point_balance')  int pointBalance, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_email_verified')  bool isEmailVerified, @JsonKey(name: 'google_id')  String? googleId, @JsonKey(name: 'is_system_admin')  bool isSystemAdmin, @JsonKey(name: 'email_verified_at')  String? emailVerifiedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phoneNumber,_that.avatarUrl,_that.pointBalance,_that.isActive,_that.isEmailVerified,_that.googleId,_that.isSystemAdmin,_that.emailVerifiedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({required this.id, @JsonKey(name: 'name') required this.fullName, required this.email, @JsonKey(name: 'phone_number') this.phoneNumber, @JsonKey(name: 'profile_picture') this.avatarUrl, @JsonKey(name: 'point_balance') this.pointBalance = 0, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_email_verified') this.isEmailVerified = false, @JsonKey(name: 'google_id') this.googleId, @JsonKey(name: 'is_system_admin') this.isSystemAdmin = false, @JsonKey(name: 'email_verified_at') this.emailVerifiedAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'name') final  String fullName;
@override final  String email;
@override@JsonKey(name: 'phone_number') final  String? phoneNumber;
@override@JsonKey(name: 'profile_picture') final  String? avatarUrl;
@override@JsonKey(name: 'point_balance') final  int pointBalance;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_email_verified') final  bool isEmailVerified;
@override@JsonKey(name: 'google_id') final  String? googleId;
@override@JsonKey(name: 'is_system_admin') final  bool isSystemAdmin;
@override@JsonKey(name: 'email_verified_at') final  String? emailVerifiedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.pointBalance, pointBalance) || other.pointBalance == pointBalance)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.googleId, googleId) || other.googleId == googleId)&&(identical(other.isSystemAdmin, isSystemAdmin) || other.isSystemAdmin == isSystemAdmin)&&(identical(other.emailVerifiedAt, emailVerifiedAt) || other.emailVerifiedAt == emailVerifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,phoneNumber,avatarUrl,pointBalance,isActive,isEmailVerified,googleId,isSystemAdmin,emailVerifiedAt,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, pointBalance: $pointBalance, isActive: $isActive, isEmailVerified: $isEmailVerified, googleId: $googleId, isSystemAdmin: $isSystemAdmin, emailVerifiedAt: $emailVerifiedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'name') String fullName, String email,@JsonKey(name: 'phone_number') String? phoneNumber,@JsonKey(name: 'profile_picture') String? avatarUrl,@JsonKey(name: 'point_balance') int pointBalance,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_email_verified') bool isEmailVerified,@JsonKey(name: 'google_id') String? googleId,@JsonKey(name: 'is_system_admin') bool isSystemAdmin,@JsonKey(name: 'email_verified_at') String? emailVerifiedAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? phoneNumber = freezed,Object? avatarUrl = freezed,Object? pointBalance = null,Object? isActive = null,Object? isEmailVerified = null,Object? googleId = freezed,Object? isSystemAdmin = null,Object? emailVerifiedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,pointBalance: null == pointBalance ? _self.pointBalance : pointBalance // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,googleId: freezed == googleId ? _self.googleId : googleId // ignore: cast_nullable_to_non_nullable
as String?,isSystemAdmin: null == isSystemAdmin ? _self.isSystemAdmin : isSystemAdmin // ignore: cast_nullable_to_non_nullable
as bool,emailVerifiedAt: freezed == emailVerifiedAt ? _self.emailVerifiedAt : emailVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
