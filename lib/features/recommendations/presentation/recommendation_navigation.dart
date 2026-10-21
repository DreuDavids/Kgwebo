import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/finance/recommendation_rules.dart';

void openRecommendationDestination(
  BuildContext context,
  RecommendationDestination destination,
) {
  switch (destination) {
    case RecommendationDestination.cashFlow:
    case RecommendationDestination.overdueCommitments:
      context.goNamed(AppRoutes.cashFlowName);
    case RecommendationDestination.transactions:
      context.goNamed(AppRoutes.transactionsName);
    case RecommendationDestination.products:
      context.goNamed(AppRoutes.productsName);
  }
}
