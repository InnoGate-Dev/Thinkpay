import 'package:flutter/material.dart';
import '../../../services/creditCardService.dart';
import '../finance/creditcardList.dart';

/// **Credit Card** tab of the loan section.
///
/// Thin composition layer: the credit card portfolio is implemented once in
/// [CreditCardListView], which the finance dashboard also uses through its own
/// route. Here the view runs header-less because `LoanHubPage` already renders
/// the page title and tab bar above it.
class CreditCardTab extends StatelessWidget {
  const CreditCardTab({super.key, this.service});

  final CreditCardService? service;

  @override
  Widget build(BuildContext context) {
    return CreditCardListView(service: service, showHeader: false);
  }
}
