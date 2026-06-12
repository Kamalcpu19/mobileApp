class User {
  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.workshopId,
    required this.workshopName,
    this.email,
    this.phone,
    this.countryCode,
  });

  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String workshopId;
  final String workshopName;
  final String? countryCode;
}
