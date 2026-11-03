import 'package:flutter/material.dart';
import '../../../services/creditCardService.dart';
import 'creadit_card_loan.dart';

/// **Credit Card** tab of the loan section.
///
/// Thin composition layer: the credit card portfolio is implemented once in
/// [CreditCardLoanView], which renders each card as a loan against its limit
/// with a used-credit progress bar and a tap-through to that card's ledger.
/// The view runs chrome-free because `LoanHubPage` already renders the page
/// title and tab bar above it.
class CreditCardTab extends StatelessWidget {
  const CreditCardTab({super.key, this.service});

  final CreditCardService? service;

  @override
  Widget build(BuildContext context) {
    return CreditCardLoanView(service: service);
  }
}
