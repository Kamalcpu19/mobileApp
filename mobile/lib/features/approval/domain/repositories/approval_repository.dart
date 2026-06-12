import '../entities/estimate.dart';
import '../entities/estimate_line_item.dart';

abstract class ApprovalRepository {
  Future<Estimate> getEstimateByToken(String token);

  Future<Estimate> submitApprovals(
    String token,
    List<({String itemId, LineItemApprovalStatus status})> approvals,
  );
}
