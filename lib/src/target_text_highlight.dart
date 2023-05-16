import 'package:flutter/material.dart';

class TargetTextHighlight {
  /// The text which on which specified style will be applied
  String targetText;

  /// User defined text style for the specific target
  TextStyle style;
  TargetTextHighlight({required this.targetText, required this.style});
}
