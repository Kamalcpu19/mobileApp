import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/complaint_remote_datasource.dart';
import '../../data/repositories/complaint_repository_impl.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaint_repository.dart';

final complaintDatasourceProvider = Provider<ComplaintRemoteDatasource>(
  (ref) => ComplaintRemoteDatasource(ref.watch(apiClientProvider)),
);

final complaintRepositoryProvider = Provider<ComplaintRepository>(
  (ref) => ComplaintRepositoryImpl(ref.watch(complaintDatasourceProvider)),
);

final complaintsProvider =
    FutureProvider.autoDispose.family<List<Complaint>, String>((ref, roId) {
  return ref.watch(complaintRepositoryProvider).getComplaints(roId);
});

final recommendationsProvider =
    FutureProvider.autoDispose.family<List<AiRecommendation>, String>(
        (ref, roId) {
  return ref.watch(complaintRepositoryProvider).getRecommendations(roId);
});

class ComplaintEntryState {
  const ComplaintEntryState({
    this.text = '',
    this.isListening = false,
    this.isSubmitting = false,
    this.isAnalyzing = false,
  });

  final String text;
  final bool isListening;
  final bool isSubmitting;
  final bool isAnalyzing;

  ComplaintEntryState copyWith({
    String? text,
    bool? isListening,
    bool? isSubmitting,
    bool? isAnalyzing,
  }) {
    return ComplaintEntryState(
      text: text ?? this.text,
      isListening: isListening ?? this.isListening,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}

final complaintEntryProvider = StateNotifierProvider.autoDispose
    .family<ComplaintEntryNotifier, ComplaintEntryState, String>(
  (ref, roId) => ComplaintEntryNotifier(ref, roId),
);

class ComplaintEntryNotifier extends StateNotifier<ComplaintEntryState> {
  ComplaintEntryNotifier(this._ref, this.roId)
      : super(const ComplaintEntryState());

  final Ref _ref;
  final String roId;

  void setText(String text) => state = state.copyWith(text: text);

  void setListening(bool listening) =>
      state = state.copyWith(isListening: listening);

  void appendVoiceText(String text) {
    final updated = state.text.isEmpty ? text : '${state.text} $text';
    state = state.copyWith(text: updated, isListening: false);
  }

  Future<void> submit() async {
    if (state.text.trim().isEmpty) return;
    state = state.copyWith(isSubmitting: true);
    try {
      await _ref.read(complaintRepositoryProvider).addComplaint(
            roId,
            state.text.trim(),
            source: state.isListening ? 'voice' : 'manual',
          );
      state = const ComplaintEntryState();
      _ref.invalidate(complaintsProvider(roId));
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> analyze() async {
    state = state.copyWith(isAnalyzing: true);
    try {
      await _ref.read(complaintRepositoryProvider).analyzeComplaints(roId);
      _ref.invalidate(recommendationsProvider(roId));
    } finally {
      state = state.copyWith(isAnalyzing: false);
    }
  }
}
