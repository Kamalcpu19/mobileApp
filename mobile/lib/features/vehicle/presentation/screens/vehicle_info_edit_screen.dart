import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../repair_order/presentation/providers/repair_order_providers.dart';
import '../providers/vehicle_providers.dart';

class VehicleInfoEditScreen extends ConsumerStatefulWidget {
  const VehicleInfoEditScreen({super.key, required this.roId});

  final String roId;

  @override
  ConsumerState<VehicleInfoEditScreen> createState() =>
      _VehicleInfoEditScreenState();
}

class _VehicleInfoEditScreenState extends ConsumerState<VehicleInfoEditScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detection = ref.read(vehicleDetectionProvider(widget.roId));
      if (detection.detectedVehicle != null) {
        ref
            .read(vehicleEditProvider(widget.roId).notifier)
            .loadFromVehicle(detection.detectedVehicle!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleEditProvider(widget.roId));
    final orderAsync = ref.watch(repairOrderDetailProvider(widget.roId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vehicle Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildField('Registration', state.registrationNumber, (v) =>
              ref.read(vehicleEditProvider(widget.roId).notifier).update('registrationNumber', v)),
          _buildField('Make', state.make,
              (v) => ref.read(vehicleEditProvider(widget.roId).notifier).update('make', v)),
          _buildField('Model', state.model,
              (v) => ref.read(vehicleEditProvider(widget.roId).notifier).update('model', v)),
          _buildField('Variant', state.variant,
              (v) => ref.read(vehicleEditProvider(widget.roId).notifier).update('variant', v)),
          _buildField('Color', state.color,
              (v) => ref.read(vehicleEditProvider(widget.roId).notifier).update('color', v)),
          _buildField('VIN', state.vin,
              (v) => ref.read(vehicleEditProvider(widget.roId).notifier).update('vin', v)),
          _buildNumberField('Year', state.year?.toString() ?? '', (v) =>
              ref.read(vehicleEditProvider(widget.roId).notifier).update('year', int.tryParse(v))),
          _buildNumberField('Odometer (km)', state.odometer?.toString() ?? '', (v) =>
              ref.read(vehicleEditProvider(widget.roId).notifier).update('odometer', int.tryParse(v))),
          _buildNumberField('Avg km/day', state.avgKmPerDay?.toString() ?? '', (v) =>
              ref.read(vehicleEditProvider(widget.roId).notifier).update('avgKmPerDay', int.tryParse(v))),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.isSaving
                ? null
                : () async {
                    await ref.read(vehicleEditProvider(widget.roId).notifier).save();
                    if (context.mounted) {
                      final vehicleId = orderAsync.valueOrNull?.vehicleId;
                      if (vehicleId != null) {
                        context.push('/vehicle-history/$vehicleId');
                      } else {
                        context.push('/repair-orders/${widget.roId}');
                      }
                    }
                  },
            child: Text(state.isSaving ? 'Saving...' : 'Save & Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        onChanged: onChanged,
      ),
    );
  }
}
