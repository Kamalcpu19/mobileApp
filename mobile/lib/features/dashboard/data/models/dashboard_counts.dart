class DashboardCounts {
  const DashboardCounts({
    required this.customerMessages,
    required this.todaysAppointments,
    required this.vehicleAttention,
    required this.pendingPayments,
  });

  final int customerMessages;
  final int todaysAppointments;
  final int vehicleAttention;
  final int pendingPayments;

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      customerMessages: _parseCount(json['customerMessages']),
      todaysAppointments: _parseCount(json['todaysAppointments']),
      vehicleAttention: _parseCount(json['vehicleAttention']),
      pendingPayments: _parseCount(json['pendingPayments']),
    );
  }

  static int _parseCount(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'customerMessages': customerMessages,
      'todaysAppointments': todaysAppointments,
      'vehicleAttention': vehicleAttention,
      'pendingPayments': pendingPayments,
    };
  }

  static const empty = DashboardCounts(
    customerMessages: 0,
    todaysAppointments: 0,
    vehicleAttention: 0,
    pendingPayments: 0,
  );
}
