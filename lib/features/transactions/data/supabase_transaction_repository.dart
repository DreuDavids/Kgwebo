import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/finance/business_calendar.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/transaction_repository.dart';
import '../application/transaction_validators.dart';
import '../domain/business_transaction.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_query.dart';
import '../domain/transaction_snapshot.dart';
import 'transaction_write_map.dart';

class SupabaseTransactionRepository implements TransactionRepository {
  SupabaseTransactionRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'transactions';
  static const _pageSize = 200;
  static const _rangeCap = 5000;

  @override
  Future<TransactionListSnapshot> list({
    required String ownerId,
    required String businessId,
    TransactionQuery query = const TransactionQuery(),
  }) async {
    _requireOwner(ownerId);
    try {
      var filter = _client.from(_table).select().eq('business_id', businessId);

      final search = query.search?.trim();
      if (search != null && search.isNotEmpty) {
        final safe = search.replaceAll(',', ' ').replaceAll('%', '');
        filter = filter.or('category.ilike.%$safe%,description.ilike.%$safe%');
      }
      if (query.type != null) {
        filter = filter.eq(
          'type',
          BusinessTransaction.typeToStorage(query.type!),
        );
      }
      final period = query.period;
      if (period != null) {
        filter = filter
            .gte('occurred_at', period.startInclusive.toIso8601String())
            .lt('occurred_at', period.endExclusive.toIso8601String());
      }
      if (query.beforeOccurredAt != null && query.beforeId != null) {
        final at = query.beforeOccurredAt!.toIso8601String();
        filter = filter.or(
          'occurred_at.lt.$at,and(occurred_at.eq.$at,id.lt.${query.beforeId})',
        );
      }

      final rows = await filter
          .order('occurred_at', ascending: false)
          .order('id', ascending: false)
          .limit(query.limit + 1);
      final items = [
        for (final row in rows)
          _owned(
            BusinessTransaction.fromMap(row, ownerId: ownerId),
            ownerId,
            businessId,
          ),
      ];
      final hasMore = items.length > query.limit;
      return TransactionListSnapshot.remote(
        hasMore ? items.sublist(0, query.limit) : items,
        hasMore: hasMore,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<List<BusinessTransaction>> listConfirmedInRange({
    required String ownerId,
    required String businessId,
    required ReportingPeriod period,
  }) async {
    _requireOwner(ownerId);
    try {
      final collected = <BusinessTransaction>[];
      var offset = 0;
      while (collected.length < _rangeCap) {
        final to = offset + _pageSize - 1;
        final rows = await _client
            .from(_table)
            .select()
            .eq('business_id', businessId)
            .gte('occurred_at', period.startInclusive.toIso8601String())
            .lt('occurred_at', period.endExclusive.toIso8601String())
            .order('occurred_at', ascending: false)
            .order('id', ascending: false)
            .range(offset, to);
        if (rows.isEmpty) {
          break;
        }
        for (final row in rows) {
          collected.add(
            _owned(
              BusinessTransaction.fromMap(row, ownerId: ownerId),
              ownerId,
              businessId,
            ),
          );
        }
        if (rows.length < _pageSize) {
          break;
        }
        offset += _pageSize;
      }
      return collected;
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<TransactionListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
    void Function(TransactionListSnapshot cached)? onLocalCache,
  }) async {
    _requireOwner(ownerId);
    try {
      final collected = <BusinessTransaction>[];
      var offset = 0;
      while (collected.length < _rangeCap) {
        final to = offset + _pageSize - 1;
        final rows = await _client
            .from(_table)
            .select()
            .eq('business_id', businessId)
            .order('occurred_at', ascending: false)
            .order('id', ascending: false)
            .range(offset, to);
        if (rows.isEmpty) {
          break;
        }
        for (final row in rows) {
          collected.add(
            _owned(
              BusinessTransaction.fromMap(row, ownerId: ownerId),
              ownerId,
              businessId,
            ),
          );
        }
        if (rows.length < _pageSize) {
          break;
        }
        offset += _pageSize;
      }
      return TransactionListSnapshot.remote(
        collected,
        hasMore: collected.length >= _rangeCap,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessTransaction?> findById({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _requireOwner(ownerId);
    try {
      final row =
          await _client
              .from(_table)
              .select()
              .eq('id', transactionId)
              .eq('business_id', businessId)
              .maybeSingle();
      if (row == null) {
        return null;
      }
      return _owned(
        BusinessTransaction.fromMap(row, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessTransaction> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    _requireOwner(ownerId);
    final errors = validateTransactionDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure('Check the amount and category and try again.');
    }
    final payload = transactionWriteMap(
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
    );
    try {
      final inserted =
          await _client.from(_table).insert(payload).select().single();
      return _owned(
        BusinessTransaction.fromMap(inserted, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      if (error is PostgrestException && error.code == '23505') {
        final existing = await _findByIdempotency(
          ownerId: ownerId,
          businessId: businessId,
          idempotencyKey: draft.idempotencyKey,
        );
        if (existing != null) {
          return existing;
        }
      }
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessTransaction> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required TransactionDraft draft,
  }) async {
    _requireOwner(ownerId);
    final existingId = draft.existingId;
    if (existingId == null) {
      throw const AuthFailure('This transaction could not be updated.');
    }
    final errors = validateTransactionDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure('Check the amount and category and try again.');
    }
    final payload = transactionWriteMap(
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
    );
    payload.remove('idempotency_key');
    payload.remove('business_id');
    try {
      final updated =
          await _client
              .from(_table)
              .update(payload)
              .eq('id', existingId)
              .eq('business_id', businessId)
              .select()
              .maybeSingle();
      if (updated == null) {
        throw const AuthFailure(
          'Could not update this transaction. It may not exist or you may not own it.',
        );
      }
      final saved = _owned(
        BusinessTransaction.fromMap(updated, ownerId: ownerId),
        ownerId,
        businessId,
      );
      if (saved.id != existingId) {
        throw const AuthFailure(
          'The server returned a different transaction than the one being edited.',
        );
      }
      return saved;
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> delete({
    required String ownerId,
    required String businessId,
    required String transactionId,
  }) async {
    _requireOwner(ownerId);
    try {
      final deleted =
          await _client
              .from(_table)
              .delete()
              .eq('id', transactionId)
              .eq('business_id', businessId)
              .select('id')
              .maybeSingle();
      if (deleted == null) {
        throw const AuthFailure(
          'Could not delete this transaction. It may not exist or you may not own it.',
        );
      }
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<BusinessTransaction?> _findByIdempotency({
    required String ownerId,
    required String businessId,
    required String idempotencyKey,
  }) async {
    final row =
        await _client
            .from(_table)
            .select()
            .eq('business_id', businessId)
            .eq('idempotency_key', idempotencyKey)
            .maybeSingle();
    if (row == null) {
      return null;
    }
    return _owned(
      BusinessTransaction.fromMap(row, ownerId: ownerId),
      ownerId,
      businessId,
    );
  }

  void _requireOwner(String ownerId) {
    final current = _client.auth.currentUser?.id;
    if (current == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    if (current != ownerId) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
  }

  BusinessTransaction _owned(
    BusinessTransaction transaction,
    String ownerId,
    String businessId,
  ) {
    if (!transaction.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This transaction does not belong to the signed-in account.',
      );
    }
    return transaction;
  }

  AuthFailure _mapError(Object error) {
    if (error is AuthFailure) {
      return error;
    }
    if (error is PostgrestException) {
      return AuthFailure.fromMessage(error.message);
    }
    if (error is SocketException ||
        error is TimeoutException ||
        error is AuthRetryableFetchException) {
      return const AuthFailure.network();
    }
    return AuthFailure.fromMessage(error.toString());
  }
}
