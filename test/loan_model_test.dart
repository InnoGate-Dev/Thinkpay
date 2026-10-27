import 'package:Thinkpay/model/loan_model.dart';
import 'package:Thinkpay/model/loan_payment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoanModel nextPaymentDate tests', () {
    test('calculate next payment date for start date in December with 0 payments made', () {
      final loan = LoanModel(
        id: 1,
        userId: 1,
        purpose: 'Test Loan',
        amount: 10000,
        interestRate: 5,
        loanDurationMonths: 12,
        monthlyPayment: 875,
        startDate: DateTime(2026, 12, 15),
        status: LoanStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 0 payments made -> next payment is 1st payment on start date (Dec 15, 2026)
      expect(loan.nextPaymentDate, DateTime(2026, 12, 15));
    });

    test('calculate next payment date for 1 payment made', () {
      final loan = LoanModel(
        id: 1,
        userId: 1,
        purpose: 'Test Loan',
        amount: 10000,
        interestRate: 5,
        loanDurationMonths: 12,
        monthlyPayment: 875,
        startDate: DateTime(2026, 12, 15),
        status: LoanStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payments: [
          LoanPaymentModel(
            id: 101,
            loanId: 1,
            amount: 875,
            paidAt: DateTime(2026, 12, 15),
          ),
        ],
      );

      // 1 payment made -> next payment date is 1 month after start date (Jan 15, 2027)
      expect(loan.nextPaymentDate, DateTime(2027, 1, 15));
    });

    test('calculate next payment date handling end of month (Jan 31)', () {
      final loan = LoanModel(
        id: 1,
        userId: 1,
        purpose: 'Test Loan',
        amount: 10000,
        interestRate: 5,
        loanDurationMonths: 12,
        monthlyPayment: 875,
        startDate: DateTime(2026, 1, 31),
        status: LoanStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        payments: [
          LoanPaymentModel(
            id: 101,
            loanId: 1,
            amount: 875,
            paidAt: DateTime(2026, 1, 31),
          ),
        ],
      );

      // 1 month after Jan 31, 2026 should be Feb 28, 2026
      expect(loan.nextPaymentDate, DateTime(2026, 2, 28));
    });
  });
}
