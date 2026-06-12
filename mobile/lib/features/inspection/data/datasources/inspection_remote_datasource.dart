import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/inspection_item.dart';
import '../models/inspection_item_model.dart';

class InspectionRemoteDatasource {
  InspectionRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<InspectionItemModel>> fetchInspectionItems(
    String repairOrderId, {
    String? type,
  }) async {
    final params = type != null ? {'type': type} : null;
    final response = await _client.get(
      '${ApiConstants.inspections}/$repairOrderId',
      queryParameters: params,
    );
    final data = response.data as List;
    return data
        .map((e) => InspectionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InspectionItemModel>> initializeInspection(
    String repairOrderId, {
    String inspectionType = 'pre',
  }) async {
    final response = await _client.post(
      '${ApiConstants.inspections}/$repairOrderId/init',
      data: {'inspectionType': inspectionType},
    );
    final data = response.data as List;
    return data
        .map((e) => InspectionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InspectionItemModel> updateInspectionItem(
    String itemId, {
    InspectionStatus? status,
    String? comment,
    String? imageUrl,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status.apiValue;
    if (comment != null) body['comment'] = comment;
    if (imageUrl != null) body['imageUrl'] = imageUrl;

    final response = await _client.patch(
      '${ApiConstants.inspections}/items/$itemId',
      data: body,
    );
    return InspectionItemModel.fromJson(response.data as Map<String, dynamic>);
  }
}
