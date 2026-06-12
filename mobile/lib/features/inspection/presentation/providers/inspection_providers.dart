import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/inspection_remote_datasource.dart';
import '../../data/repositories/inspection_repository_impl.dart';
import '../../domain/entities/inspection_item.dart';
import '../../domain/repositories/inspection_repository.dart';

final inspectionDatasourceProvider = Provider<InspectionRemoteDatasource>(
  (ref) => InspectionRemoteDatasource(ref.watch(apiClientProvider)),
);

final inspectionRepositoryProvider = Provider<InspectionRepository>(
  (ref) => InspectionRepositoryImpl(ref.watch(inspectionDatasourceProvider)),
);

final inspectionItemsProvider = FutureProvider.autoDispose
    .family<List<InspectionItem>, InspectionQuery>((ref, query) async {
  final repo = ref.watch(inspectionRepositoryProvider);
  try {
    return await repo.getInspectionItems(
      query.repairOrderId,
      type: query.type,
    );
  } catch (_) {
    return repo.initializeInspection(
      query.repairOrderId,
      inspectionType: query.type,
    );
  }
});

class InspectionQuery {
  const InspectionQuery({required this.repairOrderId, this.type = 'pre'});

  final String repairOrderId;
  final String type;

  @override
  bool operator ==(Object other) =>
      other is InspectionQuery &&
      repairOrderId == other.repairOrderId &&
      type == other.type;

  @override
  int get hashCode => Object.hash(repairOrderId, type);
}
