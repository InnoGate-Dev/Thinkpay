import 'package:Thinkpay/core/utils/number_format.dart';
import 'package:Thinkpay/ui/component/amount_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compactNumber', () {
    test('keeps everyday amounts exact, with grouping', () {
      expect(compactNumber(0), '0');
      expect(compactNumber(450), '450');
      expect(compactNumber(1250), '1,250');
      expect(compactNumber(25000), '25,000');
      expect(compactNumber(99999), '99,999');
    });

    test('abbreviates large amounts with K / M / B', () {
      expect(compactNumber(100000), '100K');
      expect(compactNumber(150000), '150K');
      expect(compactNumber(1000000), '1M');
      expect(compactNumber(1250000), '1.25M');
      expect(compactNumber(10000000), '10M');
      expect(compactNumber(2500000000), '2.5B');
    });

    test('never emits a lakh-style suffix or a 1000 unit overflow', () {
      expect(compactNumber(1000000).endsWith('L'), isFalse);
      expect(compactNumber(999999), '1M');
      expect(compactNumber(999950), '1M');
      expect(compactNumber(950000000), '950M');
      // 999.9M rounds up to a whole billion rather than printing "1000M".
      expect(compactNumber(999900000), '1B');
    });

    test('drops trailing zeros so round numbers read short', () {
      expect(compactNumber(2000000), '2M');
      expect(compactNumber(1200000), '1.2M');
    });

    test('keeps the sign in front', () {
      expect(compactNumber(-1250000), '-1.25M');
      expect(compactNumber(-450), '-450');
    });

    test('honours an explicit precision and threshold', () {
      expect(compactNumber(1250000, decimals: 1), '1.3M');
      expect(compactNumber(15000, compactFrom: 1000), '15K');
    });
  });

  group('compactMoney', () {
    test('spaces word symbols and closes glyph symbols', () {
      expect(compactMoney(1250000), 'Rs. 1.25M');
      expect(compactMoney(1250, symbol: r'$'), r'$1,250');
      expect(compactMoney(25000, symbol: '₹'), '₹25,000');
    });

    test('puts the sign before the symbol', () {
      expect(compactMoney(-2500000), '-Rs. 2.5M');
    });
  });

  group('groupedNumber', () {
    test('groups thousands and keeps requested decimals', () {
      expect(groupedNumber(1500000), '1,500,000');
      expect(groupedNumber(1250.5, decimals: 2), '1,250.50');
      expect(groupedNumber(1250.5, decimals: 2, trimZeros: true), '1,250.5');
      expect(groupedNumber(-1250), '-1,250');
    });
  });

  group('parseAmount', () {
    test('accepts grouped, compact and symbol-prefixed input', () {
      expect(parseAmount('1,200'), 1200);
      expect(parseAmount(' 1200.50 '), 1200.5);
      expect(parseAmount('Rs 1200'), 1200);
      expect(parseAmount('1.2k'), 1200);
      expect(parseAmount('1.5m'), 1500000);
      expect(parseAmount('2B'), 2000000000);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount(''), isNull);
    });
  });

  group('percentNumber', () {
    test('drops trailing zeros', () {
      expect(percentNumber(28), '28%');
      expect(percentNumber(28.5), '28.5%');
      expect(percentNumber(-2.25), '-2.25%');
    });
  });

  group('AmountText', () {
    testWidgets('shrinks instead of overflowing a narrow slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                // A deliberately tiny box for an enormous amount.
                SizedBox(
                  width: 70,
                  child: AmountText(
                    compactMoney(1234567890),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Rs. 1.23B'), findsOneWidget);
    });
  });
}
