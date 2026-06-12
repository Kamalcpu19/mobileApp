import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/approval/presentation/screens/customer_approval_screen.dart';
import '../../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../../features/appointments/presentation/screens/appointment_list_screen.dart';
import '../../features/complaints/presentation/screens/complaints_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/delivery/presentation/screens/close_job_card_screen.dart';
import '../../features/delivery/presentation/screens/delivered_screen.dart';
import '../../features/delivery/presentation/screens/delivery_review_screen.dart';
import '../../features/estimates/presentation/screens/estimate_screen.dart';
import '../../features/inspection/presentation/screens/pre_delivery_screen.dart';
import '../../features/inspection/presentation/screens/pre_inspection_screen.dart';
import '../../features/invoices/presentation/screens/invoice_screen.dart';
import '../../features/payments/presentation/screens/pending_payments_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/workspace_settings_screen.dart';
import '../../features/repair_order/presentation/screens/create_ro_screen.dart';
import '../../features/repair_order/presentation/screens/repair_order_detail_screen.dart';
import '../../features/repair_order/presentation/screens/repair_order_list_screen.dart';
import '../../features/vehicle/presentation/screens/service_history_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_detection_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_image_capture_screen.dart';
import '../../features/vehicle/presentation/screens/vehicle_info_edit_screen.dart';
import '../../features/workflow/presentation/screens/ready_for_delivery_screen.dart';
import '../../features/workflow/presentation/screens/spares_pending_screen.dart';
import '../../features/workflow/presentation/screens/work_in_progress_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.login,
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isPublicApproval = state.matchedLocation.startsWith('/approve/');

      if (isPublicApproval) return null;

      if (authState.status == AuthStatus.initial) return null;

      if (!isAuthenticated && !isLoggingIn) {
        return RoutePaths.login;
      }

      if (isAuthenticated && isLoggingIn) {
        return RoutePaths.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.appointments,
        builder: (context, state) => const AppointmentListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => AppointmentDetailScreen(
              appointmentId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.createRo,
        builder: (context, state) => CreateRoScreen(
          initialExtra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: RoutePaths.repairOrders,
        builder: (context, state) => const RepairOrderListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => RepairOrderDetailScreen(
              roId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/vehicle-detection/:roId',
        builder: (context, state) => VehicleDetectionScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/vehicle-images/:roId',
        builder: (context, state) => VehicleImageCaptureScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/vehicle-info/:roId',
        builder: (context, state) => VehicleInfoEditScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/vehicle-history/:vehicleId',
        builder: (context, state) => ServiceHistoryScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: '/inspection/:roId',
        builder: (context, state) => PreInspectionScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/pre-delivery/:roId',
        builder: (context, state) => PreDeliveryScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/complaints/:roId',
        builder: (context, state) => ComplaintsScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/estimates/:roId',
        builder: (context, state) => EstimateScreen(
          roId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/approve/:token',
        builder: (context, state) => CustomerApprovalScreen(
          token: state.pathParameters['token']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.sparesPending,
        builder: (context, state) => const SparesPendingScreen(),
      ),
      GoRoute(
        path: RoutePaths.workInProgress,
        builder: (context, state) => const WorkInProgressScreen(),
      ),
      GoRoute(
        path: RoutePaths.readyForDelivery,
        builder: (context, state) => const ReadyForDeliveryScreen(),
      ),
      GoRoute(
        path: '/repair-orders/:roId/wip',
        builder: (context, state) => WorkInProgressDetailScreen(
          repairOrderId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/repair-orders/:roId/review',
        builder: (context, state) => DeliveryReviewScreen(
          repairOrderId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/repair-orders/:roId/close-job',
        builder: (context, state) => CloseJobCardScreen(
          repairOrderId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: '/repair-orders/:roId/invoice',
        builder: (context, state) => InvoiceScreen(
          repairOrderId: state.pathParameters['roId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.delivered,
        builder: (context, state) {
          final roId = state.uri.queryParameters['roId'];
          if (roId == null) {
            return const Scaffold(
              body: Center(child: Text('Repair order ID required')),
            );
          }
          return DeliveredScreen(repairOrderId: roId);
        },
      ),
      GoRoute(
        path: RoutePaths.pendingPayments,
        builder: (context, state) => const PendingPaymentsScreen(),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.workspaceSettings,
        builder: (context, state) => const WorkspaceSettingsScreen(),
      ),
    ],
  );
});
