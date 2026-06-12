import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/estimate_line_item.dart';
import '../providers/approval_provider.dart';
import '../widgets/swipe_line_item_tile.dart';

class CustomerApprovalScreen extends ConsumerWidget {
  const CustomerApprovalScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvalProvider(token));
    final notifier = ref.read(approvalProvider(token).notifier);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return AppScaffold(
      title: 'Customer Approval',
      body: _buildBody(context, state, notifier, currency),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApprovalState state,
    ApprovalNotifier notifier,
    NumberFormat currency,
  ) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading estimate...');
    }

    if (state.error != null && state.estimate == null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => notifier.loadEstimate(token),
      );
    }

    final estimate = state.estimate;
    if (estimate == null) {
      return const AppErrorWidget(message: 'Estimate not found');
    }

    if (state.submitted) {
      return _SubmittedView(estimateNumber: estimate.estimateNumber);
    }

    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 16,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estimate.estimateNumber,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review each line item and swipe to approve or reject.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...estimate.lineItems.map(
                (item) => SwipeLineItemTile(
                  item: item,
                  enabled: !state.isSubmitting,
                  onApprove: () => notifier.updateItemStatus(
                    item.id,
                    LineItemApprovalStatus.approved,
                  ),
                  onReject: () => notifier.updateItemStatus(
                    item.id,
                    LineItemApprovalStatus.rejected,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: currency.format(estimate.subtotal)),
                      _SummaryRow(label: 'Tax', value: currency.format(estimate.taxAmount)),
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'Total',
                        value: currency.format(estimate.totalAmount),
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 32 : 16, 8, isWide ? 32 : 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: state.isSubmitting ? null : notifier.approveAll,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Approve All'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: state.isSubmitting || !estimate.hasPending
                      ? () => notifier.submit(token)
                      : () => notifier.submit(token),
                  icon: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(state.isSubmitting ? 'Submitting...' : 'Submit Approval'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmittedView extends StatelessWidget {
  const _SubmittedView({required this.estimateNumber});

  final String estimateNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Thank you!',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your approval for $estimateNumber has been submitted.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
