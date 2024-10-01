import 'package:flutter/services.dart';
import 'package:parsed_readmore/src/model/target_text_highlight.dart';

class TextHighlight {
  const TextHighlight({
    required this.targetHighlight,
    this.highlightRanges = const <TextRange>{},
  });

  final TargetTextHighlight targetHighlight;
  final Set<TextRange> highlightRanges;




  TextHighlight copyWith({
    TargetTextHighlight? targetHighlight,
    Set<TextRange>? highlightRanges,
  }) {
    return TextHighlight(
      targetHighlight: targetHighlight ?? this.targetHighlight,
      highlightRanges: highlightRanges ?? this.highlightRanges,
    );
  }

}
