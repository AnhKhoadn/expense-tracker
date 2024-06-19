import 'package:intl/intl.dart';

// helpful functions

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into viet nam dong
String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
  return format.format(amount);
}

// calculate the number of months since the first start month to know how many bars
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

// get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[now.month - 1];
}
