import 'package:intl/intl.dart';
import 'enums.dart';

final _usd = NumberFormat("\$#,##0.00", "en_US");
final _eur = NumberFormat("€#,##0.00", "en_US");
final _irr = NumberFormat(
  "#,##0",
  "fa_IR",
);
final _number = NumberFormat('#');

NumberFormat getFormater(TextFormater type) {
  switch (type) {
    case TextFormater.USD_MONEY:
      return _usd;
    case TextFormater.Number:
      return _number;
    case TextFormater.IR_MONEY:
      return _irr;
    case TextFormater.EURO_MONEY:
      return _eur;
    default:
      return _number;
  }
}
