import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/cash_outlook.dart';

enum ObligationDisplayStatus { unpaid, overdue, paid, cancelled }

class BusinessObligation {
  const BusinessObligation({
    required this.id,
    required this.businessId,
    required this.ownerId,
    required this.createdBy,
    required this.idempotencyKey,
    required this.title,
    required this.amountMinor,
    required this.currencyCode,
    required this.dueOn,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.recordedTransactionId,
    this.pendingSync = false,
  });

  final String id;
  final String businessId;
  final String ownerId;
  final String createdBy;
  final String idempotencyKey;
  final String title;
  final int amountMinor;
  final String currencyCode;
  final DateTime dueOn;
  final CommitmentStatus status;
  final String category;
  final String? notes;
  final String? recordedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pendingSync;

  bool belongsTo({required String ownerId, required String businessId}) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }

  ScheduledCommitment toScheduledCommitment() {
    if (pendingSync) {
      throw StateError('Pending commitments are not scheduled commitments.');
    }
    return ScheduledCommitment(
      id: id,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      dueOn: dueOn,
      status: status,
    );
  }

  ObligationDisplayStatus displayStatus({
    required DateTime asOf,
    BusinessZone zone = BusinessZone.africaGaborone,
  }) {
    return switch (status) {
      CommitmentStatus.paid => ObligationDisplayStatus.paid,
      CommitmentStatus.cancelled => ObligationDisplayStatus.cancelled,
      CommitmentStatus.unpaid =>
        _isOverdue(asOf: asOf, zone: zone)
            ? ObligationDisplayStatus.overdue
            : ObligationDisplayStatus.unpaid,
    };
  }

  bool _isOverdue({required DateTime asOf, required BusinessZone zone}) {
    final wall = BusinessCalendar.wallTime(asOf, zone);
    final today = DateTime(wall.year, wall.month, wall.day);
    final due = DateTime(dueOn.year, dueOn.month, dueOn.day);
    return due.isBefore(today);
  }

  factory BusinessObligation.fromMap(
    Map<String, dynamic> row, {
    required String ownerId,
  }) {
    return BusinessObligation(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      ownerId: ownerId,
      createdBy: row['created_by'] as String,
      idempotencyKey: row['idempotency_key'] as String,
      title: row['title'] as String,
      amountMinor: (row['amount_minor'] as num).toInt(),
      currencyCode: row['currency_code'] as String,
      dueOn: _date(row['due_date']),
      status: statusFromStorage(row['status'] as String),
      category: row['category'] as String,
      notes: row['notes'] as String?,
      recordedTransactionId: row['recorded_transaction_id'] as String?,
      createdAt: _stamp(row['created_at']),
      updatedAt: _stamp(row['updated_at']),
    );
  }

  static CommitmentStatus statusFromStorage(String raw) {
    return switch (raw) {
      'paid' => CommitmentStatus.paid,
      'cancelled' => CommitmentStatus.cancelled,
      'unpaid' => CommitmentStatus.unpaid,
      _ => throw FormatException('Unknown obligation status', raw),
    };
  }

  static String statusToStorage(CommitmentStatus status) {
    return switch (status) {
      CommitmentStatus.unpaid => 'unpaid',
      CommitmentStatus.paid => 'paid',
      CommitmentStatus.cancelled => 'cancelled',
    };
  }

  static DateTime _date(Object raw) {
    if (raw is DateTime) {
      return DateTime(raw.year, raw.month, raw.day);
    }
    final parsed = DateTime.parse(raw.toString());
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime _stamp(Object raw) {
    if (raw is DateTime) {
      return raw.toUtc();
    }
    return DateTime.parse(raw.toString()).toUtc();
  }
}
