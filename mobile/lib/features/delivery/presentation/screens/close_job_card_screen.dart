import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/delivery_provider.dart';

class CloseJobCardScreen extends ConsumerStatefulWidget {
  const CloseJobCardScreen({super.key, required this.repairOrderId});

  final String repairOrderId;

  @override
  ConsumerState<CloseJobCardScreen> createState() => _CloseJobCardScreenState();
}

class _CloseJobCardScreenState extends ConsumerState<CloseJobCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  DateTime? _nextServiceDate;

  @override
  void dispose() {
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(closeJobCardProvider(widget.repairOrderId));
    final notifier = ref.read(closeJobCardProvider(widget.repairOrderId).notifier);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (state.isLoading) {
      return const AppScaffold(
        title: 'Close Job Card',
        body: LoadingWidget(message: 'Loading job card...'),
      );
    }

    if (state.submitted) {
      return AppScaffold(
        title: 'Close Job Card',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 72, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Job card closed successfully'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(
                  '${RoutePaths.delivered}?roId=${widget.repairOrderId}',
                ),
                child: const Text('View Delivery Summary'),
              ),
            ],
          ),
        ),
      );
    }

    final order = state.order;

    return AppScaffold(
      title: 'Close Job Card',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          children: [
            if (order != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(order.roNumber),
                  subtitle: Text(order.vehicleLabel),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _odometerController,
              decoration: InputDecoration(
                labelText: 'Odometer Out (km)',
                hintText: order?.odometerIn != null ? 'In: ${order!.odometerIn} km' : null,
                prefixIcon: const Icon(Icons.speed),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Odometer reading is required';
                final reading = int.tryParse(value);
                if (reading == null || reading <= 0) return 'Enter a valid odometer reading';
                if (order?.odometerIn != null && reading < order!.odometerIn!) {
                  return 'Odometer out cannot be less than odometer in';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Next Service Reminder'),
              subtitle: Text(
                _nextServiceDate != null
                    ? DateFormat('dd MMM yyyy').format(_nextServiceDate!)
                    : 'Select date',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 180)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (picked != null) setState(() => _nextServiceDate = picked);
              },
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate() || _nextServiceDate == null) {
                        if (_nextServiceDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select next service date')),
                          );
                        }
                        return;
                      }
                      final success = await notifier.submit(
                        odometerOut: int.parse(_odometerController.text),
                        nextServiceReminder: _nextServiceDate!,
                      );
                      if (success && mounted) setState(() {});
                    },
              icon: state.isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.lock_outline),
              label: Text(state.isSubmitting ? 'Closing...' : 'Close Job Card'),
            ),
          ],
        ),
      ),
    );
  }
}
