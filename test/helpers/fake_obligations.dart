import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/money/money_parser.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/obligations/application/obligation_repository.dart';
import 'package:kgwebo/features/obligations/data/obligation_write_map.dart';
import 'package:kgwebo/features/obligations/domain/business_obligation.dart';
import 'package:kgwebo/features/obligations/domain/obligation_draft.dart';
import 'package:kgwebo/features/obligations/domain/obligation_snapshot.dart';

class FakeObligationRepository implements ObligationRepository {
  FakeObligationRepository({
    this.ownerId = 'user-1',
    this.businessId = 'biz-1',
  });

  final String ownerId;
  final String businessId;
  final List<BusinessObligation> items = [];
  AuthFailure? nextError;
  AuthFailure? failAfterCreate;
  Duration? createDelay;
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int listCalls = 0;

  @override
  Future<ObligationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    listCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    return ObligationListSnapshot.remote(
      items
          .where(
            (item) => item.belongsTo(ownerId: ownerId, businessId: businessId),
          )
          .toList(),
    );
  }

  @override
  Future<BusinessObligation?> findById({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    _throwIfNeeded();
    _require(ownerId, businessId);
    for (final item in items) {
      if (item.id == obligationId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId)) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<BusinessObligation> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    createCalls += 1;
    if (createDelay != null) {
      await Future<void>.delayed(createDelay!);
    }
    _throwIfNeeded();
    _require(ownerId, businessId);
    for (final item in items) {
      if (item.idempotencyKey == draft.idempotencyKey &&
          item.belongsTo(ownerId: ownerId, businessId: businessId)) {
        return item;
      }
    }
    final created = _fromDraft(
      ownerId: ownerId,
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
      id: 'ob-${items.length + 1}',
    );
    items.add(created);
    if (failAfterCreate != null) {
      final error = failAfterCreate!;
      failAfterCreate = null;
      throw error;
    }
    return created;
  }

  @override
  Future<BusinessObligation> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    updateCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    final existingId = draft.existingId;
    if (existingId == null) {
      throw const AuthFailure('This commitment could not be updated.');
    }
    final index = items.indexWhere(
      (item) =>
          item.id == existingId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (index < 0) {
      throw const AuthFailure(
        'Could not update this commitment. It may not exist or you may not own it.',
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
    required String obligationId,
  }) async {
    deleteCalls += 1;
    _throwIfNeeded();
    _require(ownerId, businessId);
    final before = items.length;
    items.removeWhere(
      (item) =>
          item.id == obligationId &&
          item.belongsTo(ownerId: ownerId, businessId: businessId),
    );
    if (items.length == before) {
      throw const AuthFailure(
        'Could not delete this commitment. It may not exist or you may not own it.',
      );
    }
  }

  BusinessObligation _fromDraft({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
    required String id,
    String? idempotencyKey,
  }) {
    final payload = obligationWriteMap(
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
    );
    final amount = tryParseMinorUnits(draft.amountText)!;
    final now = DateTime.now().toUtc();
    return BusinessObligation(
      id: id,
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      idempotencyKey: idempotencyKey ?? draft.idempotencyKey,
      title: payload['title'] as String,
      amountMinor: amount,
      currencyCode: payload['currency_code'] as String,
      dueOn: DateTime.parse(payload['due_date'] as String),
      status: draft.status,
      category: draft.category,
      notes: payload['notes'] as String?,
      createdAt: now,
      updatedAt: now,
    );
  }

  void _require(String ownerId, String businessId) {
    if (ownerId != this.ownerId || businessId != this.businessId) {
      throw const AuthFailure(
        'This commitment does not belong to the signed-in account.',
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

BusinessObligation sampleObligation({
  String id = 'ob-rent',
  String ownerId = 'user-1',
  String businessId = 'biz-1',
  int amount = 80000,
  DateTime? dueOn,
  CommitmentStatus status = CommitmentStatus.unpaid,
  String title = 'Shop rent',
  bool pendingSync = false,
}) {
  final now = DateTime.now().toUtc();
  return BusinessObligation(
    id: id,
    businessId: businessId,
    ownerId: ownerId,
    createdBy: ownerId,
    idempotencyKey: 'key-$id',
    title: title,
    amountMinor: amount,
    currencyCode: 'BWP',
    dueOn: dueOn ?? DateTime(now.year, now.month, now.day + 7),
    status: status,
    category: 'rent',
    createdAt: now,
    updatedAt: now,
    pendingSync: pendingSync,
  );
}
