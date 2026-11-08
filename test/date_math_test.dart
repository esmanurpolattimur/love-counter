import 'package:flutter_test/flutter_test.dart';

import 'package:ask_sayaci/core/utils/date_math.dart';

void main() {
  group('DateMath.calendarDaysBetween', () {
    test('normalizes time and compares calendar dates', () {
      final start = DateTime(2026, 2, 1, 23, 59);
      final end = DateTime(2026, 2, 2, 0, 1);
      expect(DateMath.calendarDaysBetween(start, end), 1);
    });

    test('handles leap day ranges', () {
      expect(DateMath.calendarDaysBetween(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
    });
  });

  group('DateMath.nextYearlyOccurrence', () {
    test('returns this year when the special date has not arrived', () {
      final value = DateMath.nextYearlyOccurrence(DateTime(2020, 12, 25), DateTime(2026, 11, 8));
      expect(value, DateTime(2026, 12, 25));
    });

    test('moves past dates to next year', () {
      final value = DateMath.nextYearlyOccurrence(DateTime(2020, 2, 14), DateTime(2026, 11, 8));
      expect(value, DateTime(2027, 2, 14));
    });

    test('uses February 28 for a February 29 yearly occurrence in non-leap years', () {
      final value = DateMath.nextYearlyOccurrence(DateTime(2024, 2, 29), DateTime(2025, 1, 1));
      expect(value, DateTime(2025, 2, 28));
    });
  });

  group('DateMath.calendarPeriod', () {
    test('calculates calendar years months and days', () {
      final period = DateMath.calendarPeriod(DateTime(2024, 1, 15), DateTime(2025, 3, 20));
      expect(period.years, 1);
      expect(period.months, 2);
      expect(period.days, 5);
    });
  });
}
