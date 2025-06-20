import 'package:intl/intl.dart';

class FormatCurrency {
  static final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );
}
