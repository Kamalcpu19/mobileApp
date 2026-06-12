import '../../domain/entities/estimate.dart';
import '../../domain/entities/estimate_line_item.dart';
import '../../domain/repositories/approval_repository.dart';
import '../datasources/approval_remote_datasource.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  ApprovalRepositoryImpl(this._remoteDataSource);

  final ApprovalRemoteDataSource _remoteDataSource;

  @override
  Future<Estimate> getEstimateByToken(String token) {
    return _remoteDataSource.getEstimateByToken(token);
  }

  @override
  Future<Estimate> submitApprovals(
    String token,
    List<({String itemId, LineItemApprovalStatus status})> approvals,
  ) {
    final payload = approvals
        .map(
          (a) => {
            'itemId': a.itemId,
            'status': switch (a.status) {
              LineItemApprovalStatus.approved => 'approved',
              LineItemApprovalStatus.rejected => 'rejected',
              LineItemApprovalStatus.pending => 'pending',
            },
          },
        )
        .toList();
    return _remoteDataSource.submitApprovals(token, payload);
  }
}
