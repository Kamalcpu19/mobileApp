import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/estimate_providers.dart';
import '../widgets/line_item_tile.dart';

class EstimateScreen extends ConsumerWidget {
  const EstimateScreen({super.key, required this.roId});

  final String roId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimateAsync = ref.watch(estimateProvider(roId));
    final formState = ref.watch(estimateFormProvider(roId));

    return Scaffold(
      appBar: AppBar(title: const Text('Estimate')),
      body: estimateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (estimate) {
          if (estimate == null) {
            return const Center(child: Text('Unable to load estimate'));
          }

          return ListView(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(estimate.estimateNumber,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Status: ${estimate.status}'),
                      const Divider(),
                      _TotalRow('Subtotal', estimate.subtotal),
                      _TotalRow('Tax', estimate.taxAmount),
                      _TotalRow('Total', estimate.totalAmount, bold: true),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('Line Items',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: formState.isGenerating
                          ? null
                          : () => ref
                              .read(estimateFormProvider(roId).notifier)
                              .generateAiQuote(),
                      icon: formState.isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        formState.isGenerating ? 'Generating...' : 'AI Quote',
                      ),
                    ),
                  ],
                ),
              ),
              if (estimate.lineItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No line items yet. Add parts or services below.'),
                )
              else
                ...estimate.lineItems.map((item) => LineItemTile(item: item)),
              const Divider(),
              ExpansionTile(
                title: const Text('Add Part / Service'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'service', label: Text('Service')),
                            ButtonSegment(value: 'part', label: Text('Part')),
                          ],
                          selected: {formState.itemType},
                          onSelectionChanged: (s) => ref
                              .read(estimateFormProvider(roId).notifier)
                              .setItemType(s.first),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Name'),
                          onChanged: ref
                              .read(estimateFormProvider(roId).notifier)
                              .setName,
                        ),
                        if (formState.itemType == 'part') ...[
                          const SizedBox(height: 8),
                          TextField(
                            decoration:
                                const InputDecoration(labelText: 'Part Number'),
                            onChanged: ref
                                .read(estimateFormProvider(roId).notifier)
                                .setPartNumber,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration:
                                    const InputDecoration(labelText: 'Qty'),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => ref
                                    .read(estimateFormProvider(roId).notifier)
                                    .setQuantity(double.tryParse(v) ?? 1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                    labelText: 'Unit Price (₹)'),
                                keyboardType: TextInputType.number,
                                onChanged: (v) => ref
                                    .read(estimateFormProvider(roId).notifier)
                                    .setUnitPrice(double.tryParse(v) ?? 0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: formState.isAdding
                              ? null
                              : () => ref
                                  .read(estimateFormProvider(roId).notifier)
                                  .addLineItem(),
                          child: Text(formState.isAdding ? 'Adding...' : 'Add Item'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => ref.invalidate(estimateProvider(roId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Generate Estimate'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: formState.isSubmitting ||
                              estimate.lineItems.isEmpty
                          ? null
                          : () => ref
                              .read(estimateFormProvider(roId).notifier)
                              .submitApproval(),
                      icon: formState.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        formState.isSubmitting
                            ? 'Submitting...'
                            : 'Submit for Approval',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.amount, {this.bold = false});

  final String label;
  final double amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: bold
                  ? Theme.of(context).textTheme.titleSmall
                  : null),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: bold
                ? Theme.of(context).textTheme.titleSmall
                : null,
          ),
        ],
      ),
    );
  }
}
