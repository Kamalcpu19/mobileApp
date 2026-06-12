import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/contact_launcher.dart';
import '../../domain/entities/pending_payment.dart';
import '../providers/payments_provider.dart';

class PaymentReminderSheet extends StatefulWidget {
  const PaymentReminderSheet({
    super.key,
    required this.payment,
    required this.onGenerate,
  });

  final PendingPayment payment;
  final Future<String> Function(ReminderMessageType type) onGenerate;

  @override
  State<PaymentReminderSheet> createState() => _PaymentReminderSheetState();
}

class _PaymentReminderSheetState extends State<PaymentReminderSheet> {
  ReminderMessageType _selectedType = ReminderMessageType.friendly;
  String? _message;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'AI Reminder Message',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.payment.customerName ?? widget.payment.invoiceNumber,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SegmentedButton<ReminderMessageType>(
            segments: ReminderMessageType.values
                .map((type) => ButtonSegment(value: type, label: Text(type.label)))
                .toList(),
            selected: {_selectedType},
            onSelectionChanged: (selection) {
              setState(() {
                _selectedType = selection.first;
                _message = null;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_message != null)
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_message!),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isGenerating
                ? null
                : () async {
                    setState(() => _isGenerating = true);
                    try {
                      final message = await widget.onGenerate(_selectedType);
                      if (mounted) setState(() => _message = message);
                    } finally {
                      if (mounted) setState(() => _isGenerating = false);
                    }
                  },
            icon: _isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Message'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Clipboard.setData(ClipboardData(text: _message!)),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: widget.payment.customerMobile != null
                        ? () => ContactLauncher.whatsApp(
                              widget.payment.customerMobile!,
                              message: _message,
                            )
                        : null,
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
