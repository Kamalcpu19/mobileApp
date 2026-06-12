import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/vehicle.dart';
import '../providers/vehicle_providers.dart';

IconData _imageTypeIcon(VehicleImageType type) {
  switch (type) {
    case VehicleImageType.front:
      return Icons.directions_car;
    case VehicleImageType.back:
      return Icons.directions_car_filled;
    case VehicleImageType.left:
      return Icons.turn_left;
    case VehicleImageType.right:
      return Icons.turn_right;
    case VehicleImageType.fuel:
      return Icons.local_gas_station;
    case VehicleImageType.odometer:
      return Icons.speed;
  }
}

class VehicleImageCaptureScreen extends ConsumerWidget {
  const VehicleImageCaptureScreen({super.key, required this.roId});

  final String roId;

  Future<void> _capture(
    WidgetRef ref,
    VehicleImageType type,
  ) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    ref
        .read(vehicleImageCaptureProvider(roId).notifier)
        .captureImage(type, file.path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleImageCaptureProvider(roId));
    final currentType = state.skipped && state.currentType == VehicleImageType.odometer
        ? VehicleImageType.odometer
        : state.currentType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Images'),
        actions: [
          if (!state.skipped)
            TextButton(
              onPressed: () =>
                  ref.read(vehicleImageCaptureProvider(roId).notifier).skipToOdometer(),
              child: const Text('Skip'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(
            value: state.captured.length / requiredImageTypes.length,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.captured.length} of ${requiredImageTypes.length} images captured',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          if (state.skipped) ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Image capture skipped. Enter odometer reading and average km/day.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Odometer (km)'),
              onChanged: (v) => ref
                  .read(vehicleImageCaptureProvider(roId).notifier)
                  .setOdometer(int.tryParse(v)),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Average km per day'),
              onChanged: (v) => ref
                  .read(vehicleImageCaptureProvider(roId).notifier)
                  .setAvgKm(int.tryParse(v)),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(_imageTypeIcon(currentType), size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Capture: ${currentType.label}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _capture(ref, currentType),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Required Images', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...requiredImageTypes.map((type) {
            final captured = state.captured.containsKey(type);
            return ListTile(
              leading: Icon(
                captured ? Icons.check_circle : Icons.radio_button_unchecked,
                color: captured ? Colors.green : Colors.grey,
              ),
              title: Text(type.label),
              trailing: captured
                  ? const Icon(Icons.image, color: Colors.green)
                  : null,
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: state.isUploading ||
                    (!state.skipped && !state.isComplete) ||
                    (state.skipped && state.odometer == null)
                ? null
                : () async {
                    final detection =
                        ref.read(vehicleDetectionProvider(roId));
                    final vehicleId = detection.detectedVehicle?.id;
                    if (vehicleId != null) {
                      await ref
                          .read(vehicleImageCaptureProvider(roId).notifier)
                          .uploadAll(vehicleId);
                    }
                    if (context.mounted) context.push('/vehicle-info/$roId');
                  },
            child: Text(state.isUploading ? 'Saving...' : 'Continue'),
          ),
        ],
      ),
    );
  }
}
