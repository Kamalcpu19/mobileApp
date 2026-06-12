import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/delivery_provider.dart';

class DeliveredScreen extends ConsumerWidget {
  const DeliveredScreen({super.key, required this.repairOrderId});

  final String repairOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveredProvider(repairOrderId));
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy');
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Delivered',
      body: _buildBody(context, state, currency, dateFormat, isWide),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DeliveredState state,
    NumberFormat currency,
    DateFormat dateFormat,
    bool isWide,
  ) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading delivery summary...');
    }

    if (state.error != null && state.order == null) {
      return AppErrorWidget(message: state.error!);
    }

    final order = state.order!;
    final invoice = state.invoice;
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(isWide ? 24 : 16),
      children: [
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.check_circle, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  'Vehicle Delivered',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text('${order.roNumber} · ${order.vehicleLabel}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Invoice', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: invoice == null
              ? const ListTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('Invoice not generated yet'),
                )
              : ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text(invoice['invoice_number']?.toString() ?? 'Invoice'),
                  subtitle: Text(
                    'Total: ${currency.format(double.tryParse(invoice['total_amount']?.toString() ?? '0') ?? 0)}',
                  ),
                  trailing: Chip(
                    label: Text(invoice['status']?.toString() ?? 'pending'),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Text('Gate Pass', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.qr_code_2),
            title: Text('Gate Pass · ${order.jobCardNumber ?? order.roNumber}'),
            subtitle: Text('Customer: ${order.customerName ?? '—'}'),
            trailing: const Icon(Icons.print_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Text('Service History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (state.serviceHistory.isEmpty)
          const Card(
            child: ListTile(
              title: Text('No prior service history on record'),
            ),
          )
        else
          ...state.serviceHistory.map(
            (entry) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(dateFormat.format(entry.serviceDate)),
                subtitle: Text(
                  [
                    if (entry.odometer != null) '${entry.odometer} km',
                    if (entry.description != null) entry.description,
                  ].whereType<String>().join(' · '),
                ),
                trailing: entry.totalAmount != null
                    ? Text(currency.format(entry.totalAmount))
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
