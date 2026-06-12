import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/appointment_providers.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync = ref.watch(appointmentDetailProvider(appointmentId));
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: appointmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (appointment) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailSection(
                title: 'Customer',
                children: [
                  _DetailRow('Name', appointment.customerName ?? '—'),
                  _DetailRow('Mobile', appointment.customerMobile ?? '—'),
                ],
              ),
              _DetailSection(
                title: 'Vehicle',
                children: [
                  _DetailRow('Registration', appointment.registrationNumber ?? '—'),
                  _DetailRow('Make / Model',
                      '${appointment.make ?? '—'} / ${appointment.model ?? '—'}'),
                ],
              ),
              _DetailSection(
                title: 'Schedule',
                children: [
                  _DetailRow('Category', appointment.category),
                  _DetailRow('Date', dateFormat.format(appointment.appointmentDate)),
                  _DetailRow('Time', appointment.appointmentTime?.substring(0, 5) ?? '—'),
                  _DetailRow('Status', appointment.status),
                  if (appointment.isAutoReminder)
                    const _DetailRow('Reminder', 'Auto Reminder'),
                ],
              ),
              if (appointment.notes != null && appointment.notes!.isNotEmpty)
                _DetailSection(
                  title: 'Notes',
                  children: [Text(appointment.notes!)],
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push(
                  '/create-ro',
                  extra: {
                    'appointmentId': appointment.id,
                    'customerId': appointment.customerId,
                    'vehicleId': appointment.vehicleId,
                  },
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Repair Order'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
