import 'package:intl/intl.dart';
import '../helpers/extendable.dart';

extension DateTimeExtendable on Extendable<DateTime> {
  String asString(String pattern) {
    return DateFormat(pattern).format(base);
  }

  String get weekdayString => switch (base.weekday) {
        1 => "Thứ hai",
        2 => "Thứ ba",
        3 => "Thứ tư",
        4 => "Thứ năm",
        5 => "Thứ sáu",
        6 => "Thứ bảy",
        7 => "Chủ nhật",
        _ => "",
      };
}
