import 'dart:math' as math;

abstract final class DateMath {
  static int calendarDaysBetween(DateTime start, DateTime end) {
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day);
    return to.difference(from).inDays;
  }

  static DateTime nextYearlyOccurrence(DateTime source, DateTime now) {
    DateTime occurrence(int year) {
      final lastDay = DateTime(year, source.month + 1, 0).day;
      return DateTime(year, source.month, math.min(source.day, lastDay));
    }
    final thisYear = occurrence(now.year);
    return thisYear.isAfter(DateTime(now.year, now.month, now.day)) ? thisYear : occurrence(now.year + 1);
  }

  static int daysUntil(DateTime date, {DateTime? now}) => math.max(0, calendarDaysBetween(now ?? DateTime.now(), date));

  static CalendarPeriod calendarPeriod(DateTime start, DateTime end) {
    var years = end.year - start.year;
    var anniversary = DateTime(start.year + years, start.month, math.min(start.day, DateTime(start.year + years, start.month + 1, 0).day));
    if (anniversary.isAfter(end)) { years--; anniversary = DateTime(start.year + years, start.month, math.min(start.day, DateTime(start.year + years, start.month + 1, 0).day)); }
    var months = (end.year - anniversary.year) * 12 + end.month - anniversary.month;
    var monthMark = DateTime(anniversary.year, anniversary.month + months, math.min(anniversary.day, DateTime(anniversary.year, anniversary.month + months + 1, 0).day));
    if (monthMark.isAfter(end)) { months--; monthMark = DateTime(anniversary.year, anniversary.month + months, math.min(anniversary.day, DateTime(anniversary.year, anniversary.month + months + 1, 0).day)); }
    return CalendarPeriod(years, months, calendarDaysBetween(monthMark, end));
  }
}

class CalendarPeriod {
  const CalendarPeriod(this.years, this.months, this.days);
  final int years;
  final int months;
  final int days;
}
