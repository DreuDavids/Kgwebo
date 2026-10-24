import 'dart:async';

import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/money/money_parser.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/transactions/application/transaction_repository.dart';
import 'package:kgwebo/features/transactions/data/transaction_write_map.dart';
import 'package:kgwebo/features/transactions/domain/business_transaction.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';
import 'package:kgwebo/features/transactions/domain/transaction_query.dart';
import 'package:kgwebo/features/transactions/domain/transaction_snapshot.dart';

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository({
    this.ownerId = 'user-1',
    this.businessId = 'biz-1',
  });

  final String ownerId;
  final String businessId;
  final List<BusinessTransaction> items = [];
  AuthFailure? nextError;
  AuthFailure? failAfterCreate;
  Duration? createDelay;
  Completer<void>? createGate;
  Completer<void>? listAllGate;
  bool allowAnyOwner = false;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int listCalls = 0;
  int listAllCalls = 0;
  void Function(int count)? onCreateEntered;
  Completer<void>? _enteredCreate;

  Future<void> get enteredCreate =>
      _enteredCreate?.future ?? Future<void>.value();

  Completer<void> armCreateGate() {
    createGate = Completer<void>();
    _enteredCreate = Completer<void>();
    return createGate!;
  }

  Completer<void> armListAllGate() {
    listAllGate = Completer<void>();
    return listAllGate!;
  }

  @override
  Future<TransactionListSnapshot> list({
    required String ownerId,
    required String businessId,
    TransactionQuery query = const TransactionQuery(),
  }) async {
    listCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    var results = items.where(
      (item) => item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    final search = query.search?.trim().toLowerCase();
    if (search != null && search.isNotEmpty) {
      results = results.where((item) {
        final description = item.description?.toLowerCase() ?? '';
        return item.category.toLowerCase().contains(search) ||
            description.contains(search);
      });
    }
    if (query.type != null) {
      results = results.where((item) => item.type == query.type);
    }
    final listed =
        results.toList()..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final hasMore = listed.length > query.limit;
    return TransactionListSnapshot.remote(
      hasMore ? listed.sublist(0, query.limit) : listed,
      hasMore: hasMore,
    );
  }

  @override
  Future<List<BusinessTransaction>> listConfirmedInRange({
    required String ownerId,
    required String businessId,
    required ReportingPeriod period,
  }) async {
    _throwIfNeeded();
    _require(ownerId, businessId);
    return items
        .where(
          (item) =>
              item.belongsTo(ownerId: ownerId, businessId: businessId) &&
              period.contains(item.occurredAt),
        )
        .toList();
  }

  @override
  Future<TransactionListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(TransactionListSnapshot cached)? onLocalCache,
  }) async {
    listAllCalls += 1;
    _require(ownerId, businessId);
    final owned =
        items
            .where(
              (item) =>
                  item.belongsTo(ownerId: ownerId, businessId: businessId),
            )
            .toList();
    if (owned.isNotEmpty) {
      onLocalCache?.call(
        TransactionListSnapshot(
          items: owned,
          origin: TransactionDataOrigin.localCache,
        ),
      );
    }
    final gate = listAllGate;
    if (gate != null) {
      await gate.future;
    }
    _throwIfNeeded();
    return TransactionListSnapshot.remote(owned);
  }

  @override
  Future<BusinessTransaction?> findById({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _throwIfNeeded();
    _require(ownerId, businessId);
    for (final item in items) {
      if (item.id == transactionId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId)) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BusinessTransaction> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    createCalls += 1;
    onCreateEntered?.call(createCalls);
    final entered = _enteredCreate;
    if (entered != null && !entered.isCompleted) {
      entered.complete();
    }
    final gate = createGate;
    if (gate != null) {
      await gate.future;
    }
    if (createDelay != null) {
      await Future<void>.delayed(createDelay!);
    }
    _throwIfNeeded();
    _require(ownerId, businessId);
    for (final item in items) {
      if (item.idempotencyKey == draft.idempotencyKey &&
          item.businessId == businessId) {
        return item;
      }
    }
    final created = _fromDraft(
      ownerId: ownerId,
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
      id: 'tx-${items.length + 1}',
    );
    items.add(created);
    final delayedError = failAfterCreate;
    failAfterCreate = null;
    if (delayedError != null) {
      throw delayedError;
    }
    return created;
  }

  @override
  Future<BusinessTransaction> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    updateCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    final existingId = draft.existingId;
    if (existingId == null) {
      throw const AuthFailure('This transaction could not be updated.');
    }
    final index = items.indexWhere(
      (item) =>
          item.id == existingId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (index < 0) {
      throw const AuthFailure(
        'Could not update this transaction. It may not exist or you may not own it.',
      );
    }
    final updated = _fromDraft(
      ownerId: ownerId,
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
      id: existingId,
      idempotencyKey: items[index].idempotencyKey,
    );
    items[index] = updated;
    return updated;
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    deleteCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    final before = items.length;
    items.removeWhere(
      (item) =>
          item.id == transactionId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (items.length == before) {
      throw const AuthFailure(
        'Could not delete this transaction. It may not exist or you may not own it.',
      );
    }
  }

  BusinessTransaction _fromDraft({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
    required String id,
    String? idempotencyKey,
  }) {
    final payload = transactionWriteMap(
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
    );
    final amount = tryParseMinorUnits(draft.amountText)!;
    final now = DateTime.now().toUtc();
    return BusinessTransaction(
      id: id,
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      idempotencyKey: idempotencyKey ?? draft.idempotencyKey,
      type: draft.type,
      amountMinor: amount,
      currencyCode: payload['currency_code'] as String,
      category: draft.category,
      description: payload['description'] as String?,
      occurredAt: DateTime.parse(payload['occurred_at'] as String).toUtc(),
      paymentMethod: draft.paymentMethod,
      paymentStatus: draft.paymentStatus,
      createdAt: now,
      updatedAt: now,
    );
  }

  void _require(String ownerId, String businessId) {
    if (allowAnyOwner) {
      return;
    }
    if (ownerId != this.ownerId || businessId != this.businessId) {
      throw const AuthFailure(
        'This transaction does not belong to the signed-in account.',
      );
    }
  }

  void _throwIfNeeded() {
    final error = nextError;
    nextError = null;
    if (error != null) {
      throw error;
    }
  }
}

BusinessTransaction sampleSale({
  String id = 'tx-sale',
  String ownerId = 'user-1',
  String businessId = 'biz-1',
  int amount = 50000,
  PaymentStatus status = PaymentStatus.paid,
  DateTime? occurredAt,
  bool pendingSync = false,
}) {
  return _sampleTransaction(
    id: id,
    ownerId: ownerId,
    businessId: businessId,
    amount: amount,
    status: status,
    occurredAt: occurredAt,
    type: MoneyMovementType.sale,
    category: 'goods',
    pendingSync: pendingSync,
  );
}

BusinessTransaction sampleExpense({
  String id = 'tx-expense',
  String ownerId = 'user-1',
  String businessId = 'biz-1',
  int amount = 80000,
  PaymentStatus status = PaymentStatus.paid,
  DateTime? occurredAt,
}) {
  return _sampleTransaction(
    id: id,
    ownerId: ownerId,
    businessId: businessId,
    amount: amount,
    status: status,
    occurredAt: occurredAt,
    type: MoneyMovementType.expense,
    category: 'rent',
  );
}

BusinessTransaction _sampleTransaction({
  required String id,
  required String ownerId,
  required String businessId,
  required int amount,
  required PaymentStatus status,
  required MoneyMovementType type,
  required String category,
  DateTime? occurredAt,
  bool pendingSync = false,
}) {
  final occurred = occurredAt ?? DateTime.now().toUtc();
  return BusinessTransaction(
    id: id,
    businessId: businessId,
    ownerId: ownerId,
    createdBy: ownerId,
    idempotencyKey: 'key-$id',
    type: type,
    amountMinor: amount,
    currencyCode: 'BWP',
    category: category,
    occurredAt: occurred,
    paymentMethod: PaymentMethod.cash,
    paymentStatus: status,
    createdAt: occurred,
    updatedAt: occurred,
    pendingSync: pendingSync,
  );
}
