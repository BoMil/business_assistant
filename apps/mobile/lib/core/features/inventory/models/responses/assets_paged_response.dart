import 'package:business_assistant/core/features/inventory/models/responses/asset_response.dart';
import 'package:business_assistant/core/shared/models/base_multi_page_response.dart';

/// A page of GET /assets/paged — mirrors the Business API's PagedResult&lt;AssetDto&gt;.
class AssetsPagedResponse extends BaseMultiPageResponse<AssetResponse> {
  AssetsPagedResponse.fromJson(Map<String, dynamic> json)
      : super(
          pageIndex: json['pageIndex'] ?? 0,
          count: json['count'] ?? 0,
          totalPages: json['totalPages'] ?? 0,
          hasPreviousPage: json['hasPreviousPage'] ?? false,
          hasNextPage: json['hasNextPage'] ?? false,
          items: json['items'] != null
              ? List<AssetResponse>.from((json['items'] as List).map((x) => AssetResponse.fromJson(x)))
              : [],
        );
}
