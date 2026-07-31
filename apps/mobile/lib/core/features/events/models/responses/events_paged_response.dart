import 'package:business_assistant/core/features/events/models/responses/event_response.dart';
import 'package:business_assistant/core/shared/models/base_multi_page_response.dart';

/// A page of GET /transactions — mirrors the Business API's PagedResult&lt;TransactionDto&gt;.
class EventsPagedResponse extends BaseMultiPageResponse<EventResponse> {
  EventsPagedResponse.fromJson(Map<String, dynamic> json)
      : super(
          pageIndex: json['pageIndex'] ?? 0,
          count: json['count'] ?? 0,
          totalPages: json['totalPages'] ?? 0,
          hasPreviousPage: json['hasPreviousPage'] ?? false,
          hasNextPage: json['hasNextPage'] ?? false,
          items: json['items'] != null
              ? List<EventResponse>.from((json['items'] as List).map((x) => EventResponse.fromJson(x)))
              : [],
        );

  /// Used to build a page directly from in-memory items — only needed by
  /// EventApiService's temporary mock data (see its TODOs).
  EventsPagedResponse({
    required super.pageIndex,
    required super.count,
    required super.totalPages,
    required super.items,
    required super.hasPreviousPage,
    required super.hasNextPage,
  });
}
