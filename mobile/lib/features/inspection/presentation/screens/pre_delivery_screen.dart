import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/inspection_providers.dart';
import '../widgets/inspection_swipe_tile.dart';
import '../../domain/entities/inspection_item.dart';

class PreDeliveryScreen extends ConsumerWidget {
  const PreDeliveryScreen({super.key, required this.roId});

  final String roId;

  Map<String, List<InspectionItem>> _groupByCategory(List<InspectionItem> items) {
    final grouped = <String, List<InspectionItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = InspectionQuery(repairOrderId: roId, type: 'delivery');
    final itemsAsync = ref.watch(inspectionItemsProvider(query));

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Delivery Checklist')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final grouped = _groupByCategory(items);
          final completed = items
              .where((i) => i.status != InspectionStatus.pending)
              .length;

          return Column(
            children: [
              LinearProgressIndicator(value: items.isEmpty ? 0 : completed / items.length),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('$completed of ${items.length} items checked'),
              ),
              Expanded(
                child: ListView(
                  children: grouped.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(entry.key,
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      ...entry.value.map((item) => InspectionSwipeTile(
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
                            onImageTap: () async {
                              final file = await ImagePicker()
                                  .pickImage(source: ImageSource.camera);
                              if (file == null) return;
                              await ref
                                  .read(inspectionRepositoryProvider)
                                  .updateInspectionItem(
                                    item.id,
                                    imageUrl: file.path,
                                  );
                              ref.invalidate(inspectionItemsProvider(query));
                            },
                          )),
                    ];
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
