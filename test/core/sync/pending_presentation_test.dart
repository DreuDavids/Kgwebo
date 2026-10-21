import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/cash_outlook.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/sync/outbox_models.dart';
import 'package:kgwebo/core/sync/pending_presentation.dart';
import 'package:kgwebo/features/obligations/domain/business_obligation.dart';
import 'package:kgwebo/features/transactions/domain/payment_method.dart';
import 'package:kgwebo/features/transactions/domain/transaction_draft.dart';

import '../../helpers/fake_transactions.dart';

void main() {
  final october = ReportingPeriod(
    startInclusive: BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 1,
    ),
    endExclusive: BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 11,
      day: 1,
    ),
  );

  OutboxOperation pendingOp({
    String operationId = 'op-1',
    String idempotencyKey = 'pending-key',
    OutboxState state = OutboxState.pending,
    PaymentStatus paymentStatus = PaymentStatus.paid,
  }) {
    final payload = CreateTransactionPayload.fromDraft(
      currencyCode: 'BWP',
      draft: TransactionDraft(
        type: MoneyMovementType.sale,
        amountText: '500.00',
        occurredOn: DateTime(2026, 10, 10),
        category: 'goods',
        paymentMethod: PaymentMethod.cash,
        paymentStatus: paymentStatus,
        idempotencyKey: idempotencyKey,
      ),
    );
    return OutboxOperation(
      operationId: operationId,
      ownerId: 'user-1',
      businessId: 'biz-1',
      operationType: OutboxOperationTypes.createTransactionV1,
      payloadJson: payload.encode(),
      idempotencyKey: idempotencyKey,
      createdAt: DateTime.utc(2026, 10, 10),
      state: state,
    );
  }

  test(
    'hides a pending row once a confirmed copy shares the idempotency key',
    () {
      final confirmed = sampleSale(occurredAt: DateTime.utc(2026, 10, 10));
      final merged = mergePendingTransactions(
        confirmed: [confirmed],
        operations: [pendingOp(idempotencyKey: confirmed.idempotencyKey)],
      );
      expect(merged, hasLength(1));
      expect(merged.single.id, confirmed.id);
      expect(merged.single.pendingSync, isFalse);
    },
  );

  test('keeps pending and confirmed rows distinguishable', () {
    final merged = mergePendingTransactions(
      confirmed: [sampleSale(occurredAt: DateTime.utc(2026, 10, 10))],
      operations: [pendingOp()],
    );
    expect(merged, hasLength(2));
    expect(merged.where((item) => item.pendingSync), hasLength(1));
    expect(merged.where((item) => !item.pendingSync), hasLength(1));
  });

  test('financial engine totals ignore pending rows', () {
    final confirmed = sampleSale(occurredAt: DateTime.utc(2026, 10, 10, 10));
    final pending = pendingOp().asCreateTransaction().toPendingTransaction(
      operationId: 'op-1',
      ownerId: 'user-1',
      businessId: 'biz-1',
      createdAt: DateTime.utc(2026, 10, 10),
    );
    expect(pending.pendingSync, isTrue);
    expect(() => pending.toLedgerEntry(), throwsStateError);
    final summary = FinancialEngine.summarize(
      entries: confirmedLedgerEntries([confirmed, pending]),
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: DateTime.utc(2026, 10, 21),
    );
    expect(summary.recordedSalesMinor, 50000);
    expect(summary.countedEntries, 1);
    expect(summary.currentCashMinor, 250000);
  });

  test('unpaid pending sales are not treated as cash', () {
    final unpaidPending = pendingOp(
      idempotencyKey: 'unpaid-pending',
      paymentStatus: PaymentStatus.unpaid,
    ).asCreateTransaction().toPendingTransaction(
      operationId: 'op-unpaid',
      ownerId: 'user-1',
      businessId: 'biz-1',
      createdAt: DateTime.utc(2026, 10, 10),
    );
    final summary = FinancialEngine.summarize(
      entries: confirmedLedgerEntries([unpaidPending]),
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: DateTime.utc(2026, 10, 21),
    );
    expect(summary.recordedSalesMinor, 0);
    expect(summary.currentCashMinor, 200000);
    expect(summary.countedEntries, 0);
  });

  test('pending commitments are not expenses or outlook inputs', () {
    final pending = BusinessObligation(
      id: 'pending:op-rent',
      businessId: 'biz-1',
      ownerId: 'user-1',
      createdBy: 'user-1',
      idempotencyKey: 'pending-rent',
      title: 'Shop rent',
      amountMinor: 80000,
      currencyCode: 'BWP',
      dueOn: DateTime(2026, 10, 28),
      status: CommitmentStatus.unpaid,
      category: 'rent',
      createdAt: DateTime.utc(2026, 10, 10),
      updatedAt: DateTime.utc(2026, 10, 10),
      pendingSync: true,
    );
    expect(() => pending.toScheduledCommitment(), throwsStateError);
    final outlook = CashOutlookEngine.summarize(
      currentCashMinor: 200000,
      currencyCode: 'BWP',
      asOf: DateTime.utc(2026, 10, 21),
      zone: BusinessZone.africaGaborone,
      commitments: [
        for (final item in [pending])
          if (!item.pendingSync) item.toScheduledCommitment(),
      ],
    );
    expect(outlook.unpaidCommitmentsMinor, 0);
    expect(outlook.estimatedCashAfterCommitmentsMinor, 200000);
    expect(outlook.countedCommitments, 0);
  });
}
