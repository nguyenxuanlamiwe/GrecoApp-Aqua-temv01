import 'package:flutter/material.dart';
import 'package:zen8app/utils/helpers/extendable.dart';

extension ColorExtendable on Extendable<Color> {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${base.alpha.toRadixString(16).padLeft(2, '0')}'
      '${base.red.toRadixString(16).padLeft(2, '0')}'
      '${base.green.toRadixString(16).padLeft(2, '0')}'
      '${base.blue.toRadixString(16).padLeft(2, '0')}';
}
