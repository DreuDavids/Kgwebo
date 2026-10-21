import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/ledger_entry.dart';

class TransactionQuery {
  const TransactionQuery({
    this.search,
    this.type,
    this.period,
    this.limit = 50,
    this.beforeOccurredAt,
    this.beforeId,
  });

  final String? search;
  final MoneyMovementType? type;
  final ReportingPeriod? period;
  final int limit;
  final DateTime? beforeOccurredAt;
  final String? beforeId;

  TransactionQuery copyWith({
    String? search,
    MoneyMovementType? type,
    ReportingPeriod? period,
    int? limit,
    DateTime? beforeOccurredAt,
    String? beforeId,
    bool clearSearch = false,
    bool clearType = false,
    bool clearPeriod = false,
    bool clearCursor = false,
  }) {
    return TransactionQuery(
      search: clearSearch ? null : (search ?? this.search),
      type: clearType ? null : (type ?? this.type),
      period: clearPeriod ? null : (period ?? this.period),
      limit: limit ?? this.limit,
      beforeOccurredAt:
          clearCursor ? null : (beforeOccurredAt ?? this.beforeOccurredAt),
      beforeId: clearCursor ? null : (beforeId ?? this.beforeId),
    );
  }
}
