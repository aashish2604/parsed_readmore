import 'package:flutter/material.dart';

enum TargetTextHighlightType {
  /// if the string match is with in word then it will not be highlighted
  word,
  /// if the string match is with in URL (http or https) then it
  /// will not be highlighted
  stringMatch,
}

class TargetTextHighlight {
  /// The regex pattern to match the target text
  final String targetText;

  /// User defined text style for the specific target
  final TextStyle style;

  /// Callback function to be called when the highlight text is clicked
  final void Function(TextRange range)? onTap;

  /// Highlight type to determine if the highlight is for whole word or string match
  final TargetTextHighlightType targetTextHighlightType;

// if case sensitive is true
  final bool caseSensitive;

  const TargetTextHighlight({
    required this.targetText,
    required this.style,
    this.onTap,
    this.targetTextHighlightType = TargetTextHighlightType.word,
    this.caseSensitive = false,
  });
}
