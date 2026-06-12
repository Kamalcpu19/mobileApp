import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/complaint_providers.dart';
import '../widgets/recommendation_card.dart';

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key, required this.roId});

  final String roId;

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  final _textController = TextEditingController();
  final _speech = stt.SpeechToText();
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    ref.read(complaintEntryProvider(widget.roId).notifier).setListening(true);
    await _speech.listen(
      onResult: (result) {
        ref
            .read(complaintEntryProvider(widget.roId).notifier)
            .setText(result.recognizedWords);
        if (result.finalResult) {
          ref
              .read(complaintEntryProvider(widget.roId).notifier)
              .setListening(false);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    ref.read(complaintEntryProvider(widget.roId).notifier).setListening(false);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(complaintEntryProvider(widget.roId));
    final complaintsAsync = ref.watch(complaintsProvider(widget.roId));
    final recommendationsAsync = ref.watch(recommendationsProvider(widget.roId));

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Complaints')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Describe complaint',
                    hintText: 'Enter customer complaint manually...',
                  ),
                  onChanged: ref
                      .read(complaintEntryProvider(widget.roId).notifier)
                      .setText,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: entryState.isListening
                            ? _stopListening
                            : _startListening,
                        icon: Icon(
                          entryState.isListening ? Icons.mic : Icons.mic_none,
                          color: entryState.isListening ? Colors.red : null,
                        ),
                        label: Text(
                          entryState.isListening ? 'Stop' : 'Voice to Text',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: entryState.isSubmitting
                          ? null
                          : () async {
                              await ref
                                  .read(complaintEntryProvider(widget.roId)
                                      .notifier)
                                  .submit();
                              _textController.clear();
                            },
                      child: Text(
                        entryState.isSubmitting ? '...' : 'Add',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Complaints',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          complaintsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
            data: (complaints) {
              if (complaints.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No complaints recorded yet'),
                );
              }
              return Column(
                children: complaints
                    .map((c) => ListTile(
                          leading: Icon(
                            c.source == 'voice' ? Icons.mic : Icons.edit,
                          ),
                          title: Text(c.description),
                          subtitle: Text(c.status),
                        ))
                    .toList(),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('AI Recommendations',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: entryState.isAnalyzing
                      ? null
                      : () => ref
                          .read(complaintEntryProvider(widget.roId).notifier)
                          .analyze(),
                  icon: entryState.isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(entryState.isAnalyzing ? 'Analyzing...' : 'Analyze'),
                ),
              ],
            ),
          ),
          recommendationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $e'),
            ),
            data: (recommendations) {
              if (recommendations.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Run AI analysis to get recommendations'),
                );
              }
              return Column(
                children: recommendations
                    .map((rec) => RecommendationCard(
                          recommendation: rec,
                          onToggle: (selected) async {
                            await ref
                                .read(complaintRepositoryProvider)
                                .toggleRecommendation(rec.id, selected);
                            ref.invalidate(
                                recommendationsProvider(widget.roId));
                          },
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
