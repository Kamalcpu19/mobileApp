import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.workshopId,
    required this.workshopName,
    this.workshopAddress,
    this.workshopPhone,
    this.workshopEmail,
  });

  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String workshopId;
  final String workshopName;
  final String? workshopAddress;
  final String? workshopPhone;
  final String? workshopEmail;

  @override
  List<Object?> get props => [id, username, workshopId];
}

class AutomationSettings extends Equatable {
  const AutomationSettings({
    required this.vehicleIdentificationEnabled,
    required this.complaintsAiEnabled,
    required this.aiQuoteAgentEnabled,
  });

  final bool vehicleIdentificationEnabled;
  final bool complaintsAiEnabled;
  final bool aiQuoteAgentEnabled;

  @override
  List<Object?> get props => [
        vehicleIdentificationEnabled,
        complaintsAiEnabled,
        aiQuoteAgentEnabled,
      ];
}
