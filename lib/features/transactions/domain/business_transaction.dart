import '../../../core/finance/ledger_entry.dart';
import 'payment_method.dart';

class BusinessTransaction {
  const BusinessTransaction({
    required this.id,
    required this.businessId,
    required this.ownerId,
    required this.createdBy,
    required this.idempotencyKey,
    required this.type,
    required this.amountMinor,
    required this.currencyCode,
    required this.category,
    required this.occurredAt,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String businessId;
  final String ownerId;
  final String createdBy;
  final String idempotencyKey;
  final MoneyMovementType type;
  final int amountMinor;
  final String currencyCode;
  final String category;
  final String? description;
  final DateTime occurredAt;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool belongsTo({required String ownerId, required String businessId}) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }

  LedgerEntry toLedgerEntry() {
    return LedgerEntry(
      id: id,
      type: type,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      occurredAt: occurredAt,
      paymentStatus: paymentStatus,
    );
  }

  factory BusinessTransaction.fromMap(
    Map<String, dynamic> row, {
    required String ownerId,
  }) {
    return BusinessTransaction(
      id: row['id'] as String,
      businessId: row['business_id'] as String,
      ownerId: ownerId,
      createdBy: row['created_by'] as String,
      idempotencyKey: row['idempotency_key'] as String,
      type: typeFromStorage(row['type'] as String),
      amountMinor: (row['amount_minor'] as num).toInt(),
      currencyCode: row['currency_code'] as String,
      category: row['category'] as String,
      description: row['description'] as String?,
      occurredAt: _stamp(row['occurred_at']),
      paymentMethod: PaymentMethodCodec.fromStorage(
        row['payment_method'] as String,
      ),
      paymentStatus: statusFromStorage(row['payment_status'] as String),
      createdAt: _stamp(row['created_at']),
      updatedAt: _stamp(row['updated_at']),
    );
  }

  static MoneyMovementType typeFromStorage(String raw) {
    return switch (raw) {
      'sale' => MoneyMovementType.sale,
      'expense' => MoneyMovementType.expense,
      'refund' => MoneyMovementType.refund,
      'owner_contribution' => MoneyMovementType.ownerContribution,
      'owner_withdrawal' => MoneyMovementType.ownerWithdrawal,
      _ => throw FormatException('Unknown transaction type', raw),
    };
  }

  static PaymentStatus statusFromStorage(String raw) {
    return switch (raw) {
      'paid' => PaymentStatus.paid,
      'unpaid' => PaymentStatus.unpaid,
      _ => throw FormatException('Unknown payment status', raw),
    };
  }

  static String typeToStorage(MoneyMovementType type) {
    return switch (type) {
      MoneyMovementType.sale => 'sale',
      MoneyMovementType.expense => 'expense',
      MoneyMovementType.refund => 'refund',
      MoneyMovementType.ownerContribution => 'owner_contribution',
      MoneyMovementType.ownerWithdrawal => 'owner_withdrawal',
    };
  }

  static String statusToStorage(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.paid => 'paid',
      PaymentStatus.unpaid => 'unpaid',
    };
  }

  static DateTime _stamp(Object raw) {
    if (raw is DateTime) {
      return raw.toUtc();
    }
    final parsed = DateTime.tryParse(raw as String)?.toUtc();
    if (parsed == null) {
      throw FormatException('Invalid timestamp', raw);
    }
    return parsed;
  }
}
