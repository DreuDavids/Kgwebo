import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../authentication/domain/auth_failure.dart';
import '../application/obligation_repository.dart';
import '../application/obligation_validators.dart';
import '../domain/business_obligation.dart';
import '../domain/obligation_draft.dart';
import '../domain/obligation_snapshot.dart';
import 'obligation_write_map.dart';

class SupabaseObligationRepository implements ObligationRepository {
  SupabaseObligationRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'obligations';

  @override
  Future<ObligationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    _requireOwner(ownerId);
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('business_id', businessId)
          .order('due_date', ascending: true)
          .order('id', ascending: true);
      return ObligationListSnapshot.remote([
        for (final row in rows)
          _owned(
            BusinessObligation.fromMap(row, ownerId: ownerId),
            ownerId,
            businessId,
          ),
      ]);
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessObligation?> findById({
    required String ownerId,
    required String businessId,
    required String obligationId,
  }) async {
    _requireOwner(ownerId);
    try {
      final row =
          await _client
              .from(_table)
              .select()
              .eq('id', obligationId)
              .eq('business_id', businessId)
              .maybeSingle();
      if (row == null) {
        return null;
      }
      return _owned(
        BusinessObligation.fromMap(row, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessObligation> create({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    _requireOwner(ownerId);
    final errors = validateObligationDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure(
        'Check the amount, title and category and try again.',
      );
    }
    final payload = obligationWriteMap(
      businessId: businessId,
      currencyCode: currencyCode,
      draft: draft,
    );
    try {
      final inserted =
          await _client.from(_table).insert(payload).select().single();
      return _owned(
        BusinessObligation.fromMap(inserted, ownerId: ownerId),
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
  Future<BusinessObligation> update({
    required String ownerId,
    required String businessId,
    required String currencyCode,
    required ObligationDraft draft,
  }) async {
    _requireOwner(ownerId);
    final existingId = draft.existingId;
    if (existingId == null) {
      throw const AuthFailure('This commitment could not be updated.');
    }
    final errors = validateObligationDraft(draft);
    if (errors.hasErrors) {
      throw const AuthFailure(
        'Check the amount, title and category and try again.',
      );
    }
    final payload = obligationWriteMap(
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
          'Could not update this commitment. It may not exist or you may not own it.',
        );
      }
      final saved = _owned(
        BusinessObligation.fromMap(updated, ownerId: ownerId),
        ownerId,
        businessId,
      );
      if (saved.id != existingId) {
        throw const AuthFailure(
          'The server returned a different commitment than the one being edited.',
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
    required String obligationId,
  }) async {
    _requireOwner(ownerId);
    try {
      final deleted =
          await _client
              .from(_table)
              .delete()
              .eq('id', obligationId)
              .eq('business_id', businessId)
              .select('id')
              .maybeSingle();
      if (deleted == null) {
        throw const AuthFailure(
          'Could not delete this commitment. It may not exist or you may not own it.',
        );
      }
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<BusinessObligation?> _findByIdempotency({
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
      BusinessObligation.fromMap(row, ownerId: ownerId),
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

  BusinessObligation _owned(
    BusinessObligation obligation,
    String ownerId,
    String businessId,
  ) {
    if (!obligation.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This commitment does not belong to the signed-in account.',
      );
    }
    return obligation;
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
