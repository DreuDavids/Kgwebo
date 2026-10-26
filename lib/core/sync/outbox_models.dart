import 'dart:convert';

import '../../features/obligations/data/obligation_write_map.dart';
import '../../features/obligations/domain/business_obligation.dart';
import '../../features/obligations/domain/obligation_draft.dart';
import '../../features/transactions/data/transaction_write_map.dart';
import '../../features/transactions/domain/business_transaction.dart';
import '../../features/transactions/domain/payment_method.dart';
import '../../features/transactions/domain/transaction_draft.dart';
import '../../features/authentication/domain/auth_failure.dart';
import '../finance/business_calendar.dart';
import '../finance/cash_outlook.dart';
import '../finance/ledger_entry.dart';
import '../logging/app_logger.dart';
import '../money/amount_text.dart';

enum OutboxState {
  pending,
  syncing,
  succeeded,
  retryableFailure,
  permanentFailure,
}

extension OutboxStateCodec on OutboxState {
  String get storageValue {
    return switch (this) {
      OutboxState.pending => 'pending',
      OutboxState.syncing => 'syncing',
      OutboxState.succeeded => 'succeeded',
      OutboxState.retryableFailure => 'retryable_failure',
      OutboxState.permanentFailure => 'permanent_failure',
    };
  }

  String get userLabel {
    return switch (this) {
      OutboxState.pending => 'Waiting to save',
      OutboxState.syncing => 'Saving',
      OutboxState.succeeded => 'Saved',
      OutboxState.retryableFailure => 'Could not save. Will try again',
      OutboxState.permanentFailure => 'Needs review',
    };
  }

  bool get isOpen => this != OutboxState.succeeded;

  bool get canProcessAutomatically =>
      this == OutboxState.pending || this == OutboxState.retryableFailure;

  bool get needsUserAction => this == OutboxState.permanentFailure;

  static OutboxState fromStorage(String raw) {
    return switch (raw) {
      'pending' => OutboxState.pending,
      'syncing' => OutboxState.syncing,
      'succeeded' => OutboxState.succeeded,
      'retryable_failure' => OutboxState.retryableFailure,
      'permanent_failure' => OutboxState.permanentFailure,
      _ => throw FormatException('Unknown outbox state', raw),
    };
  }
}

abstract final class OutboxOperationTypes {
  static const createTransactionV1 = 'create_transaction.v1';
  static const createObligationV1 = 'create_obligation.v1';
}

abstract final class SyncPolicy {
  static const maxAutomaticAttempts = 8;
  static const Duration maxBackoff = Duration(minutes: 15);
  static const Duration dispatchTimeout = Duration(seconds: 45);

  static Duration backoffFor(int attemptCount) {
    final exponent = attemptCount.clamp(0, 10);
    final seconds = 1 << exponent;
    final duration = Duration(seconds: seconds);
    if (duration > maxBackoff) {
      return maxBackoff;
    }
    return duration;
  }

  static bool isRetryable(Object error) {
    if (error is AuthFailure) {
      if (error.code == 'session_expired') {
        return true;
      }
      return error.isRetryable;
    }
    return false;
  }

  static String safeMessage(Object error) {
    if (error is AuthFailure) {
      return AppLogger.redactSecrets(error.message);
    }
    return AppLogger.redactSecrets(error.toString());
  }

  static String? safeCode(Object error) {
    if (error is AuthFailure) {
      return error.code;
    }
    return error.runtimeType.toString();
  }
}

class OutboxOperation {
  const OutboxOperation({
    required this.operationId,
    required this.ownerId,
    required this.businessId,
    required this.operationType,
    required this.payloadJson,
    required this.idempotencyKey,
    required this.createdAt,
    required this.state,
    this.attemptCount = 0,
    this.lastAttemptAt,
    this.nextAttemptAt,
    this.lastErrorCode,
    this.lastErrorMessage,
    this.dependsOnOperationId,
    this.succeededAt,
  });

  final String operationId;
  final String ownerId;
  final String businessId;
  final String operationType;
  final String payloadJson;
  final String idempotencyKey;
  final DateTime createdAt;
  final OutboxState state;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  final String? lastErrorMessage;
  final String? dependsOnOperationId;
  final DateTime? succeededAt;

  bool belongsTo({required String ownerId, required String businessId}) {
    return this.ownerId == ownerId && this.businessId == businessId;
  }

  bool get isCreateTransaction =>
      operationType == OutboxOperationTypes.createTransactionV1;

  bool get isCreateObligation =>
      operationType == OutboxOperationTypes.createObligationV1;

  Map<String, dynamic> payloadMap() {
    final decoded = jsonDecode(payloadJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Outbox payload must be a JSON object.');
    }
    return decoded;
  }

  CreateTransactionPayload asCreateTransaction() {
    return CreateTransactionPayload.fromJson(payloadMap());
  }

  CreateObligationPayload asCreateObligation() {
    return CreateObligationPayload.fromJson(payloadMap());
  }

  OutboxOperation copyWith({
    OutboxState? state,
    int? attemptCount,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    String? lastErrorCode,
    String? lastErrorMessage,
    DateTime? succeededAt,
    bool clearNextAttempt = false,
    bool clearError = false,
  }) {
    return OutboxOperation(
      operationId: operationId,
      ownerId: ownerId,
      businessId: businessId,
      operationType: operationType,
      payloadJson: payloadJson,
      idempotencyKey: idempotencyKey,
      createdAt: createdAt,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextAttemptAt:
          clearNextAttempt ? null : (nextAttemptAt ?? this.nextAttemptAt),
      lastErrorCode: clearError ? null : (lastErrorCode ?? this.lastErrorCode),
      lastErrorMessage:
          clearError ? null : (lastErrorMessage ?? this.lastErrorMessage),
      dependsOnOperationId: dependsOnOperationId,
      succeededAt: succeededAt ?? this.succeededAt,
    );
  }
}

class CreateTransactionPayload {
  const CreateTransactionPayload({
    required this.currencyCode,
    required this.type,
    required this.amountMinor,
    required this.category,
    required this.occurredAt,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.idempotencyKey,
    this.description,
  });

  final String currencyCode;
  final MoneyMovementType type;
  final int amountMinor;
  final String category;
  final DateTime occurredAt;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String idempotencyKey;
  final String? description;

  factory CreateTransactionPayload.fromDraft({
    required String currencyCode,
    required TransactionDraft draft,
  }) {
    final map = transactionWriteMap(
      businessId: 'payload',
      currencyCode: currencyCode,
      draft: draft,
    );
    return CreateTransactionPayload(
      currencyCode: currencyCode,
      type: draft.type,
      amountMinor: map['amount_minor'] as int,
      category: draft.category.trim(),
      occurredAt: DateTime.parse(map['occurred_at'] as String).toUtc(),
      paymentMethod: draft.paymentMethod,
      paymentStatus: draft.paymentStatus,
      idempotencyKey: draft.idempotencyKey,
      description: map['description'] as String?,
    );
  }

  factory CreateTransactionPayload.fromJson(Map<String, dynamic> json) {
    return CreateTransactionPayload(
      currencyCode: json['currencyCode'] as String,
      type: BusinessTransaction.typeFromStorage(json['type'] as String),
      amountMinor: (json['amountMinor'] as num).toInt(),
      category: json['category'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String).toUtc(),
      paymentMethod: PaymentMethodCodec.fromStorage(
        json['paymentMethod'] as String,
      ),
      paymentStatus: BusinessTransaction.statusFromStorage(
        json['paymentStatus'] as String,
      ),
      idempotencyKey: json['idempotencyKey'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'type': BusinessTransaction.typeToStorage(type),
      'amountMinor': amountMinor,
      'category': category,
      'occurredAt': occurredAt.toIso8601String(),
      'paymentMethod': paymentMethod.storageValue,
      'paymentStatus': BusinessTransaction.statusToStorage(paymentStatus),
      'idempotencyKey': idempotencyKey,
      'description': description,
    };
  }

  String encode() => jsonEncode(toJson());

  TransactionDraft toDraft() {
    final wall = BusinessCalendar.gaboroneWallTime(occurredAt);
    return TransactionDraft(
      type: type,
      amountText: amountTextFromMinor(amountMinor),
      occurredOn: DateTime(wall.year, wall.month, wall.day),
      category: category,
      description: description ?? '',
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      idempotencyKey: idempotencyKey,
    );
  }

  BusinessTransaction toPendingTransaction({
    required String operationId,
    required String ownerId,
    required String businessId,
    required DateTime createdAt,
  }) {
    return BusinessTransaction(
      id: 'pending:$operationId',
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      idempotencyKey: idempotencyKey,
      type: type,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      category: category,
      description: description,
      occurredAt: occurredAt,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
      updatedAt: createdAt,
      pendingSync: true,
    );
  }
}

class CreateObligationPayload {
  const CreateObligationPayload({
    required this.currencyCode,
    required this.title,
    required this.amountMinor,
    required this.dueOn,
    required this.category,
    required this.status,
    required this.idempotencyKey,
    this.notes,
  });

  final String currencyCode;
  final String title;
  final int amountMinor;
  final DateTime dueOn;
  final String category;
  final CommitmentStatus status;
  final String idempotencyKey;
  final String? notes;

  factory CreateObligationPayload.fromDraft({
    required String currencyCode,
    required ObligationDraft draft,
  }) {
    final map = obligationWriteMap(
      businessId: 'payload',
      currencyCode: currencyCode,
      draft: draft,
    );
    return CreateObligationPayload(
      currencyCode: currencyCode,
      title: draft.title.trim(),
      amountMinor: map['amount_minor'] as int,
      dueOn: DateTime.parse(map['due_date'] as String),
      category: draft.category.trim(),
      status: draft.status,
      idempotencyKey: draft.idempotencyKey,
      notes: map['notes'] as String?,
    );
  }

  factory CreateObligationPayload.fromJson(Map<String, dynamic> json) {
    return CreateObligationPayload(
      currencyCode: json['currencyCode'] as String,
      title: json['title'] as String,
      amountMinor: (json['amountMinor'] as num).toInt(),
      dueOn: DateTime.parse(json['dueOn'] as String),
      category: json['category'] as String,
      status: BusinessObligation.statusFromStorage(json['status'] as String),
      idempotencyKey: json['idempotencyKey'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'title': title,
      'amountMinor': amountMinor,
      'dueOn':
          '${dueOn.year.toString().padLeft(4, '0')}-${dueOn.month.toString().padLeft(2, '0')}-${dueOn.day.toString().padLeft(2, '0')}',
      'category': category,
      'status': BusinessObligation.statusToStorage(status),
      'idempotencyKey': idempotencyKey,
      'notes': notes,
    };
  }

  String encode() => jsonEncode(toJson());

  ObligationDraft toDraft() {
    return ObligationDraft(
      title: title,
      amountText: amountTextFromMinor(amountMinor),
      dueOn: DateTime(dueOn.year, dueOn.month, dueOn.day),
      category: category,
      status: status,
      notes: notes ?? '',
      idempotencyKey: idempotencyKey,
    );
  }

  BusinessObligation toPendingObligation({
    required String operationId,
    required String ownerId,
    required String businessId,
    required DateTime createdAt,
  }) {
    return BusinessObligation(
      id: 'pending:$operationId',
      businessId: businessId,
      ownerId: ownerId,
      createdBy: ownerId,
      idempotencyKey: idempotencyKey,
      title: title,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      dueOn: DateTime(dueOn.year, dueOn.month, dueOn.day),
      status: status,
      category: category,
      notes: notes,
      createdAt: createdAt,
      updatedAt: createdAt,
      pendingSync: true,
    );
  }
}
