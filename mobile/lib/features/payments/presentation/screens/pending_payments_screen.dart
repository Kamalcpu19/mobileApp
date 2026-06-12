import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/contact_launcher.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/pending_payment.dart';
import '../providers/payments_provider.dart';
import '../widgets/payment_reminder_sheet.dart';

class PendingPaymentsScreen extends ConsumerWidget {
  const PendingPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pendingPaymentsProvider);
    final notifier = ref.read(pendingPaymentsProvider.notifier);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy');
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Pending Payments',
      body: _buildBody(context, ref, state, notifier, currency, dateFormat, isWide),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    PendingPaymentsState state,
    PendingPaymentsNotifier notifier,
    NumberFormat currency,
    DateFormat dateFormat,
    bool isWide,
  ) {
    if (state.isLoading && state.payments.isEmpty) {
      return const LoadingWidget(message: 'Loading pending payments...');
    }

    if (state.error != null && state.payments.isEmpty) {
      return AppErrorWidget(message: state.error!, onRetry: notifier.load);
    }

    if (state.payments.isEmpty) {
      return const Center(child: Text('No pending payments'));
    }

    return RefreshIndicator(
      onRefresh: notifier.load,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
        itemCount: state.payments.length,
        itemBuilder: (context, index) {
          final payment = state.payments[index];
          return _PaymentCard(
            payment: payment,
            currency: currency,
            dateFormat: dateFormat,
            onReminder: () => _showReminderSheet(context, ref, payment),
            onSendLink: () {
              if (payment.paymentLink != null) {
                ContactLauncher.openUrl(payment.paymentLink!);
              }
            },
          );
        },
      ),
    );
  }

  void _showReminderSheet(BuildContext context, WidgetRef ref, PendingPayment payment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => PaymentReminderSheet(
        payment: payment,
        onGenerate: (type) => ref.read(pendingPaymentsProvider.notifier).generateReminder(payment, type),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.currency,
    required this.dateFormat,
    required this.onReminder,
    required this.onSendLink,
  });

  final PendingPayment payment;
  final NumberFormat currency;
  final DateFormat dateFormat;
  final VoidCallback onReminder;
  final VoidCallback onSendLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = payment.dueDate != null && payment.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    payment.customerName ?? 'Customer',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  currency.format(payment.dueAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? theme.colorScheme.error : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${payment.vehicleLabel} · ${payment.invoiceNumber}'),
            if (payment.dueDate != null)
              Text(
                'Due ${dateFormat.format(payment.dueDate!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Call',
                  onPressed: payment.customerMobile != null
                      ? () => ContactLauncher.call(payment.customerMobile!)
                      : null,
                  icon: const Icon(Icons.call),
                ),
                IconButton.filledTonal(
                  tooltip: 'WhatsApp',
                  onPressed: payment.customerMobile != null
                      ? () => ContactLauncher.whatsApp(payment.customerMobile!)
                      : null,
                  icon: const Icon(Icons.chat),
                ),
                IconButton.filledTonal(
                  tooltip: 'SMS',
                  onPressed: payment.customerMobile != null
                      ? () => ContactLauncher.sms(payment.customerMobile!)
                      : null,
                  icon: const Icon(Icons.sms_outlined),
                ),
                IconButton.filledTonal(
                  tooltip: 'Email',
                  onPressed: payment.customerEmail != null
                      ? () => ContactLauncher.email(payment.customerEmail!)
                      : null,
                  icon: const Icon(Icons.email_outlined),
                ),
                TextButton.icon(
                  onPressed: payment.paymentLink != null ? onSendLink : null,
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Payment Link'),
                ),
                TextButton.icon(
                  onPressed: onReminder,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('AI Reminder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
