class AppDateFormatter {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Format any ISO 8601 string, DateTime, or timestamp into standard 12-hour format with AM/PM.
  /// Example: "27 Aug 2026, 10:05 AM"
  static String formatDateTime(dynamic input) {
    if (input == null) return '-';

    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty || trimmed == '-' || trimmed == 'null' || trimmed == 'undefined') {
        return '-';
      }

      // If already formatted like "27 Aug 2026, 10:05 AM" or "27 Aug 2026", return directly
      final formattedRegex = RegExp(
        r'^\d{1,2}\s+[A-Za-z]{3,}\s+\d{4}(,\s+\d{1,2}:\d{2}(\s*[AP]M)?)?$',
        caseSensitive: false,
      );
      if (formattedRegex.hasMatch(trimmed)) {
        return trimmed;
      }

      try {
        final parsed = DateTime.parse(trimmed).toLocal();
        return _formatDateTimeObject(parsed);
      } catch (_) {
        return trimmed;
      }
    } else if (input is DateTime) {
      return _formatDateTimeObject(input.toLocal());
    }

    return input.toString();
  }

  /// Format only date: "27 Aug 2026"
  static String formatDateOnly(dynamic input) {
    if (input == null) return '-';

    if (input is String) {
      try {
        final parsed = DateTime.parse(input).toLocal();
        final day = parsed.day.toString().padLeft(2, '0');
        final month = _months[parsed.month - 1];
        return '$day $month ${parsed.year}';
      } catch (_) {
        return input;
      }
    } else if (input is DateTime) {
      final dt = input.toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = _months[dt.month - 1];
      return '$day $month ${dt.year}';
    }

    return input.toString();
  }

  static String _formatDateTimeObject(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _months[dt.month - 1];
    final year = dt.year;

    int hour = dt.hour % 12;
    if (hour == 0) hour = 12;
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$day $month $year, $hourStr:$minuteStr $ampm';
  }
}
