import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zen8app/utils/utils.dart';

extension StringExtendable on Extendable<String> {
  bool isValidEmail() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(base);
  }

  bool isValidPhoneNumber() {
    return RegExp(
            r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
        .hasMatch(base);
  }

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  Color toColor() {
    final buffer = StringBuffer();
    if (base.length == 6 || base.length == 7) buffer.write('ff');
    buffer.write(base.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  DateTime? asDateTime(String pattern) {
    try {
      final dateTime = DateFormat(pattern).parse(base);
      return dateTime;
    } catch (e) {
      return null;
    }
  }
}
