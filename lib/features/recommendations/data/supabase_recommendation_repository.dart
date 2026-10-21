import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/finance/recommendation_lifecycle.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/recommendation_repository.dart';
import '../domain/business_recommendation.dart';
import '../domain/recommendation_snapshot.dart';
import 'recommendation_write_map.dart';

class SupabaseRecommendationRepository implements RecommendationRepository {
  SupabaseRecommendationRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'recommendations';

  @override
  Future<RecommendationListSnapshot> listAllConfirmed({
    required String ownerId,
    required String businessId,
  }) async {
    _requireOwner(ownerId);
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('business_id', businessId)
          .order('rule_key', ascending: true)
          .order('id', ascending: true);
      return RecommendationListSnapshot.remote([
        for (final row in rows)
          _owned(
            BusinessRecommendation.fromMap(row, ownerId: ownerId),
            ownerId,
            businessId,
          ),
      ]);
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessRecommendation> upsert({
    required String ownerId,
    required String businessId,
    required RecommendationMutation mutation,
  }) async {
    _requireOwner(ownerId);
    final payload = recommendationWriteMap(
      businessId: businessId,
      mutation: mutation,
    );
    try {
      if (mutation.existingId != null) {
        payload.remove('business_id');
        payload.remove('rule_key');
        final updated =
            await _client
                .from(_table)
                .update(payload)
                .eq('id', mutation.existingId!)
                .eq('business_id', businessId)
                .select()
                .maybeSingle();
        if (updated == null) {
          throw const AuthFailure(
            'Could not update this recommendation. It may not exist or you may not own it.',
          );
        }
        return _owned(
          BusinessRecommendation.fromMap(updated, ownerId: ownerId),
          ownerId,
          businessId,
        );
      }
      final upserted =
          await _client
              .from(_table)
              .upsert(payload, onConflict: 'business_id,rule_key')
              .select()
              .single();
      return _owned(
        BusinessRecommendation.fromMap(upserted, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessRecommendation> dismiss({
    required String ownerId,
    required String businessId,
    required String recommendationId,
    required String conditionKey,
  }) async {
    _requireOwner(ownerId);
    try {
      final updated =
          await _client
              .from(_table)
              .update({
                'status': RecommendationLifecycle.statusToStorage(
                  RecommendationStatus.dismissed,
                ),
                'condition_key': conditionKey,
              })
              .eq('id', recommendationId)
              .eq('business_id', businessId)
              .select()
              .maybeSingle();
      if (updated == null) {
        throw const AuthFailure(
          'Could not dismiss this recommendation. It may not exist or you may not own it.',
        );
      }
      return _owned(
        BusinessRecommendation.fromMap(updated, ownerId: ownerId),
        ownerId,
        businessId,
      );
    } catch (error) {
      throw _mapError(error);
    }
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

  BusinessRecommendation _owned(
    BusinessRecommendation recommendation,
    String ownerId,
    String businessId,
  ) {
    if (!recommendation.belongsTo(ownerId: ownerId, businessId: businessId)) {
      throw const AuthFailure(
        'This recommendation does not belong to the signed-in account.',
      );
    }
    return recommendation;
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
