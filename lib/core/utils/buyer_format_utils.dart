/// Formats a numeric price with thousands separators, e.g. 125000 -> "125,000".
/// Pure presentation helper — no locale/currency logic, just digit grouping.
String formatBuyerPrice(num value) {
  final String digits = value.round().abs().toString();
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    final int remaining = digits.length - i;
    if (i > 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  final String formatted = buffer.toString();
  return value < 0 ? '-$formatted' : formatted;
}
