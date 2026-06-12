import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.fullName,
    super.email,
    super.phone,
    required super.role,
    super.avatarUrl,
    required super.workshopId,
    required super.workshopName,
    super.workshopAddress,
    super.workshopPhone,
    super.workshopEmail,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'service_advisor',
      avatarUrl: json['avatar_url'] as String?,
      workshopId: json['workshop_id'] as String,
      workshopName: json['workshop_name'] as String,
      workshopAddress: json['address'] as String?,
      workshopPhone: json['workshop_phone'] as String?,
      workshopEmail: json['workshop_email'] as String?,
    );
  }
}

class AutomationSettingsModel extends AutomationSettings {
  const AutomationSettingsModel({
    required super.vehicleIdentificationEnabled,
    required super.complaintsAiEnabled,
    required super.aiQuoteAgentEnabled,
  });

  factory AutomationSettingsModel.fromJson(Map<String, dynamic> json) {
    return AutomationSettingsModel(
      vehicleIdentificationEnabled: json['vehicle_identification_enabled'] as bool? ?? true,
      complaintsAiEnabled: json['complaints_ai_enabled'] as bool? ?? true,
      aiQuoteAgentEnabled: json['ai_quote_agent_enabled'] as bool? ?? true,
    );
  }
}
