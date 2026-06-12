import 'package:flutter_test/flutter_test.dart';

import 'package:workshop_service_advisor/core/constants/app_constants.dart';
import 'package:workshop_service_advisor/core/utils/validators.dart';
import 'package:workshop_service_advisor/features/dashboard/data/models/dashboard_counts.dart';

void main() {
  group('Validators', () {
    test('required returns error for empty value', () {
      expect(Validators.required(null, fieldName: 'Username'), isNotNull);
      expect(Validators.required('', fieldName: 'Username'), isNotNull);
      expect(Validators.required('  ', fieldName: 'Username'), isNotNull);
    });

    test('required returns null for valid value', () {
      expect(Validators.required('advisor', fieldName: 'Username'), isNull);
    });
  });

  group('DashboardCounts', () {
    test('fromJson parses API response', () {
      final counts = DashboardCounts.fromJson({
        'customerMessages': 2,
        'todaysAppointments': 4,
        'vehicleAttention': 1,
        'pendingPayments': 3,
      });

      expect(counts.customerMessages, 2);
      expect(counts.todaysAppointments, 4);
      expect(counts.vehicleAttention, 1);
      expect(counts.pendingPayments, 3);
    });

    test('empty has zero counts', () {
      expect(DashboardCounts.empty.customerMessages, 0);
      expect(DashboardCounts.empty.pendingPayments, 0);
    });
  });

  group('AppConstants', () {
    test('repair order stages include delivered', () {
      expect(AppConstants.repairOrderStages, contains('delivered'));
      expect(AppConstants.repairOrderStages.first, 'inspection');
    });

    test('inspection statuses include swipe actions', () {
      expect(AppConstants.inspectionStatuses, contains('ok'));
      expect(AppConstants.inspectionStatuses, contains('urgent'));
    });
  });
}
