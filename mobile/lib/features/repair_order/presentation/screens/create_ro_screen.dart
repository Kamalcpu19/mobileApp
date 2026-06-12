import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repair_order_providers.dart';

class CreateRoScreen extends ConsumerStatefulWidget {
  const CreateRoScreen({super.key, this.initialExtra});

  final Map<String, dynamic>? initialExtra;

  @override
  ConsumerState<CreateRoScreen> createState() => _CreateRoScreenState();
}

class _CreateRoScreenState extends ConsumerState<CreateRoScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createRoProvider.notifier).initFromExtra(widget.initialExtra);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final order = await ref.read(createRoProvider.notifier).submit();
    if (!mounted || order == null) return;
    context.go('/vehicle-detection/${order.id}');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createRoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Repair Order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Linked Data',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.event,
                    label: 'Appointment',
                    value: state.appointmentId ?? 'None (walk-in)',
                  ),
                  _InfoTile(
                    icon: Icons.person,
                    label: 'Customer',
                    value: state.customerId ?? 'To be captured',
                  ),
                  _InfoTile(
                    icon: Icons.directions_car,
                    label: 'Vehicle',
                    value: state.vehicleId ?? 'To be detected',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Advisor Notes',
              hintText: 'Optional notes for this RO...',
            ),
            onChanged: ref.read(createRoProvider.notifier).setNotes,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: state.isSubmitting ? null : _submit,
            icon: state.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(state.isSubmitting ? 'Creating...' : 'Create RO'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
