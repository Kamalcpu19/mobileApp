import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/inspection_providers.dart';
import '../widgets/inspection_swipe_tile.dart';
import '../../domain/entities/inspection_item.dart';

class PreInspectionScreen extends ConsumerWidget {
  const PreInspectionScreen({super.key, required this.roId});

  final String roId;

  Map<String, List<InspectionItem>> _groupByCategory(List<InspectionItem> items) {
    final grouped = <String, List<InspectionItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  Future<void> _pickImage(
    WidgetRef ref,
    InspectionItem item,
  ) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    await ref.read(inspectionRepositoryProvider).updateInspectionItem(
          item.id,
          imageUrl: file.path,
        );
    ref.invalidate(inspectionItemsProvider(
      InspectionQuery(repairOrderId: roId, type: 'pre'),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = InspectionQuery(repairOrderId: roId, type: 'pre');
    final itemsAsync = ref.watch(inspectionItemsProvider(query));

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Inspection Checklist')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final grouped = _groupByCategory(items);
          final categories = grouped.keys.toList()..sort();

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Swipe tiles to mark OK / Action Required / Urgent',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ...categories.expand((category) {
                return [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...grouped[category]!.map((item) {
                    return Dismissible(
                      key: ValueKey(item.id),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Text('OK', style: TextStyle(color: Colors.white)),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Text('URGENT',
                            style: TextStyle(color: Colors.white)),
                      ),
                      confirmDismiss: (direction) async {
                        final status = direction == DismissDirection.startToEnd
                            ? InspectionStatus.ok
                            : InspectionStatus.urgent;
                        await ref
                            .read(inspectionRepositoryProvider)
                            .updateInspectionItem(item.id, status: status);
                        ref.invalidate(inspectionItemsProvider(query));
                        return false;
                      },
                      child: InspectionSwipeTile(
                        item: item,
                        onStatusChanged: (status) async {
                          await ref
                              .read(inspectionRepositoryProvider)
                              .updateInspectionItem(item.id, status: status);
                          ref.invalidate(inspectionItemsProvider(query));
                        },
                        onCommentChanged: (comment) async {
                          await ref
                              .read(inspectionRepositoryProvider)
                              .updateInspectionItem(item.id, comment: comment);
                        },
                        onImageTap: () => _pickImage(ref, item),
                      ),
                    );
                  }),
                ];
              }),
            ],
          );
        },
      ),
    );
  }
}
