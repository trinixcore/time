/// Date formatting constants
class DateFormats {
  // Standard Date Formats
  static const String standardDate = 'yyyy-MM-dd';
  static const String displayDate = 'MMM dd, yyyy';
  static const String fullDate = 'EEEE, MMMM dd, yyyy';
  static const String shortDate = 'MM/dd/yyyy';
  static const String compactDate = 'yyyyMMdd';

  // Time Formats
  static const String standardTime = 'HH:mm';
  static const String displayTime = 'h:mm a';
  static const String fullTime = 'HH:mm:ss';
  static const String timeWithSeconds = 'h:mm:ss a';

  // DateTime Formats
  static const String standardDateTime = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateTime = 'MMM dd, yyyy h:mm a';
  static const String fullDateTime = 'EEEE, MMMM dd, yyyy h:mm:ss a';
  static const String isoDateTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
  static const String compactDateTime = 'yyyyMMddHHmmss';

  // Month/Year Formats
  static const String monthYear = 'MMMM yyyy';
  static const String shortMonthYear = 'MMM yyyy';
  static const String numericMonthYear = 'MM/yyyy';

  // Week Formats
  static const String weekDay = 'EEEE';
  static const String shortWeekDay = 'EEE';
  static const String weekDayDate = 'EEE, MMM dd';

  // Relative Time Formats
  static const String timeAgo = 'relative'; // Used with timeago package

  // File/Log Formats
  static const String logTimestamp = 'yyyy-MM-dd_HH-mm-ss';
  static const String fileTimestamp = 'yyyyMMdd_HHmmss';

  // Report Formats
  static const String reportDate = 'MMMM dd, yyyy';
  static const String reportDateTime = 'MMMM dd, yyyy \'at\' h:mm a';

  // Calendar Formats
  static const String calendarHeader = 'MMMM yyyy';
  static const String calendarDay = 'dd';
  static const String calendarWeekDay = 'EEE';

  // Input Formats (for parsing)
  static const List<String> inputDateFormats = [
    'yyyy-MM-dd',
    'MM/dd/yyyy',
    'dd/MM/yyyy',
    'MMM dd, yyyy',
    'MMMM dd, yyyy',
  ];

  static const List<String> inputTimeFormats = [
    'HH:mm',
    'h:mm a',
    'HH:mm:ss',
    'h:mm:ss a',
  ];

  // Validation Patterns
  static const String datePattern = r'^\d{4}-\d{2}-\d{2}$';
  static const String timePattern = r'^\d{2}:\d{2}$';
  static const String dateTimePattern =
      r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$';
}
