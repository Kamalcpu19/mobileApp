import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/utils/contact_launcher.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/invoice_provider.dart';

class InvoiceScreen extends ConsumerWidget {
  const InvoiceScreen({super.key, required this.repairOrderId});

  final String repairOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invoiceProvider(repairOrderId));
    final notifier = ref.read(invoiceProvider(repairOrderId).notifier);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Invoice',
      body: _buildBody(context, state, notifier, currency, isWide),
    );
  }

  Widget _buildBody(
    BuildContext context,
    InvoiceState state,
    InvoiceNotifier notifier,
    NumberFormat currency,
    bool isWide,
  ) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading invoice...');
    }

    final theme = Theme.of(context);
    final invoice = state.invoice;

    if (invoice == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              const Text('No invoice generated yet'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: state.isGenerating ? null : notifier.generateInvoice,
                icon: state.isGenerating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.add),
                label: Text(state.isGenerating ? 'Generating...' : 'Generate Invoice'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(invoice.invoiceNumber, style: theme.textTheme.titleLarge),
                    Chip(label: Text(invoice.status)),
                  ],
                ),
                const SizedBox(height: 16),
                _AmountRow(label: 'Subtotal', value: currency.format(invoice.subtotal)),
                _AmountRow(label: 'Tax', value: currency.format(invoice.taxAmount)),
                const Divider(height: 24),
                _AmountRow(
                  label: 'Total',
                  value: currency.format(invoice.totalAmount),
                  emphasized: true,
                ),
                _AmountRow(label: 'Paid', value: currency.format(invoice.paidAmount)),
                _AmountRow(
                  label: 'Due',
                  value: currency.format(invoice.dueAmount),
                  emphasized: invoice.dueAmount > 0,
                  color: invoice.dueAmount > 0 ? theme.colorScheme.error : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('PDF', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(state.pdfPlaceholderGenerated ? 'PDF ready (placeholder)' : 'Generate PDF'),
            subtitle: Text(
              state.pdfPlaceholderGenerated
                  ? 'PDF generation will be connected to backend'
                  : 'Tap to create invoice PDF placeholder',
            ),
            trailing: FilledButton.tonal(
              onPressed: notifier.generatePdfPlaceholder,
              child: const Text('Generate'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Share Invoice', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ShareButton(
              icon: Icons.download,
              label: 'Download',
              onPressed: () => _showShareSnackBar(context, 'Download placeholder'),
            ),
            _ShareButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              onPressed: () => ContactLauncher.whatsApp(
                '',
                message: 'Invoice ${invoice.invoiceNumber}: ${currency.format(invoice.totalAmount)}',
              ),
            ),
            _ShareButton(
              icon: Icons.email_outlined,
              label: 'Email',
              onPressed: () => ContactLauncher.email(
                '',
                subject: 'Invoice ${invoice.invoiceNumber}',
                body: 'Please find your invoice for ${currency.format(invoice.totalAmount)}',
              ),
            ),
            _ShareButton(
              icon: Icons.sms_outlined,
              label: 'SMS',
              onPressed: () => ContactLauncher.sms(
                '',
                body: 'Invoice ${invoice.invoiceNumber}: ${currency.format(invoice.totalAmount)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
          ),
        if (!invoice.isPaid) ...[
          FilledButton.icon(
            onPressed: state.isPaying ? null : notifier.payNow,
            icon: state.isPaying
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.payment),
            label: Text(state.isPaying ? 'Processing...' : 'Pay Now'),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: invoice.paymentLink != null
              ? () => ContactLauncher.openUrl(invoice.paymentLink!)
              : null,
          icon: const Icon(Icons.link),
          label: const Text('Send Payment Link'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: invoice.paymentLink != null
              ? () async {
                  await Clipboard.setData(ClipboardData(text: invoice.paymentLink!));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment link copied')),
                    );
                  }
                }
              : null,
          icon: const Icon(Icons.copy),
          label: const Text('Copy Link'),
        ),
      ],
    );
  }

  void _showShareSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.color,
  });

  final String label;
  final String value;
  final bool emphasized;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasized
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)
        : theme.textTheme.bodyMedium?.copyWith(color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
