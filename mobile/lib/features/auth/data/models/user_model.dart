import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.role,
    required super.workshopId,
    required super.workshopName,
    super.email,
    super.phone,
    super.countryCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? '',
      workshopId: (json['workshopId'] ?? json['workshop_id'])?.toString() ?? '',
      workshopName:
          json['workshopName'] as String? ?? json['workshop_name'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'workshopId': workshopId,
      'workshopName': workshopName,
      'countryCode': countryCode,
    };
  }

  User toEntity() => User(
        id: id,
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        workshopId: workshopId,
        workshopName: workshopName,
        countryCode: countryCode,
      );
}
