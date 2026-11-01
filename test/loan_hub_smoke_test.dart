import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Thinkpay/model/credit_card_model.dart';
import 'package:Thinkpay/model/loan_model.dart';
import 'package:Thinkpay/model/loan_payment_model.dart';
import 'package:Thinkpay/services/creditCardService.dart';
import 'package:Thinkpay/services/loan_service.dart';
import 'package:Thinkpay/ui/component/navbar.dart';
import 'package:Thinkpay/ui/pages/loan/loan_hub_page.dart';

class _FakeLoanService extends LoanService {
  _FakeLoanService({this.loans = const []});
  final List<LoanModel> loans;

  @override
  Future<List<LoanModel>> fetchLoans() async => loans;

  @override
  Future<List<LoanPaymentModel>> fetchPayments(int loanId) async => <LoanPaymentModel>[];
}

class _FakeCardService extends CreditCardService {
  _FakeCardService({this.cards = const []});
  final List<CreditCardModel> cards;

  @override
  Future<List<CreditCardModel>> fetchCards() async => cards;
}

LoanModel _loan() => LoanModel(
      id: 1,
      userId: 1,
      purpose: 'Car loan',
      amount: 500000,
      interestRate: 12,
      loanDurationMonths: 24,
      monthlyPayment: 23500,
      startDate: DateTime(2026, 1, 1),
      status: LoanStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

CreditCardModel _card() => CreditCardModel(
      id: 1,
      name: 'Visa Signature',
      creditLimit: 250000,
      apr: 24,
      statementDay: 20,
      graceDays: 25,
    );

void main() {
  testWidgets('loan hub shows both tabs and swaps content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoanHubPage(
          loanService: _FakeLoanService(),
          creditCardService: _FakeCardService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bank & Finance'), findsOneWidget);
    expect(find.text('Credit Card'), findsOneWidget);
    expect(find.text('No loans yet'), findsOneWidget);

    await tester.tap(find.text('Credit Card'));
    await tester.pumpAndSettle();

    expect(find.text('No loans yet'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('each tab renders its own populated portfolio', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoanHubPage(
          loanService: _FakeLoanService(loans: [_loan()]),
          creditCardService: _FakeCardService(cards: [_card()]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Loans'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsWidgets);

    await tester.tap(find.text('Credit Card'));
    await tester.pumpAndSettle();

    expect(find.text('Visa Signature'), findsOneWidget);
    expect(find.text('Add card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nav bar stays visible when the drawer notifier is stale', (tester) async {
    // Simulates a previous shell left behind with an open drawer.
    drawerOpenNotifier.value = true;

    await tester.pumpWidget(MaterialApp(home: const AppShell(initialIndex: 2)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(drawerOpenNotifier.value, isFalse);
    final slides = tester.widgetList<AnimatedSlide>(find.byType(AnimatedSlide));
    expect(slides.any((s) => s.offset == const Offset(0, 1)), isFalse);
  });
}
