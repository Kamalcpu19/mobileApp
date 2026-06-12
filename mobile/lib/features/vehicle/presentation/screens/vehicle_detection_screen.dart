import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/vehicle_providers.dart';

class VehicleDetectionScreen extends ConsumerWidget {
  const VehicleDetectionScreen({super.key, required this.roId});

  final String roId;

  Future<void> _capturePlate(WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final base64 = base64Encode(bytes);
    await ref.read(vehicleDetectionProvider(roId).notifier).scanPlate(base64);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleDetectionProvider(roId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Detection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.center_focus_strong,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Capture license plate for OCR detection',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: state.isScanning
                        ? null
                        : () => _capturePlate(ref),
                    icon: state.isScanning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(state.isScanning ? 'Scanning...' : 'Scan Plate'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Or enter registration manually'),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Registration Number',
              hintText: 'e.g. KA01AB1234',
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: ref.read(vehicleDetectionProvider(roId).notifier).setRegistration,
            controller: TextEditingController(text: state.registrationNumber)
              ..selection = TextSelection.collapsed(
                offset: state.registrationNumber.length,
              ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: state.isLookingUp
                ? null
                : () => ref.read(vehicleDetectionProvider(roId).notifier).lookup(),
            icon: state.isLookingUp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(state.isLookingUp ? 'Looking up...' : 'Lookup Vehicle'),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(state.error!, style: const TextStyle(color: Colors.red)),
          ],
          if (state.detectedVehicle != null) ...[
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(state.detectedVehicle!.displayName),
                subtitle: Text(
                  '${state.detectedVehicle!.make ?? ''} ${state.detectedVehicle!.model ?? ''}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/vehicle-images/$roId'),
              child: const Text('Continue to Image Capture'),
            ),
          ],
        ],
      ),
    );
  }
}
