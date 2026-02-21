import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isVerified;
  final String? buildingId;
  final bool isProfilePublic;
  final bool hideAvatar;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isVerified,
    this.buildingId,
    required this.isProfilePublic,
    required this.hideAvatar,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool,
      buildingId: json['building_id'] as String?,
      isProfilePublic: json['is_profile_public'] as bool? ?? true,
      hideAvatar: json['hide_avatar'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    role,
    isVerified,
    buildingId,
    isProfilePublic,
    hideAvatar,
    avatarUrl,
  ];
}
