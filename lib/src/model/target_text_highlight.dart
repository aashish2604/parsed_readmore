import 'package:flutter/material.dart';

class TargetTextHighlight {
  const TargetTextHighlight({
    required this.targetText,
    required this.style,
    required this.priority,
    this.onTap,
    this.caseSensitive = false,
    this.highlightInUrl = false,
  });

  /// The regex pattern to match the target text
  final String targetText;

  /// User defined text style for the specific target
  final TextStyle style;

  /// Callback function to be called when the highlight text is clicked
  final void Function(TextRange range)? onTap;

  /// If the pattern is found with-in a URL, below boolean let user set if
  /// the pattern in the URL should be highlighted or not
  final bool highlightInUrl;


  /// if case sensitive is true
  final bool caseSensitive;

  /// Which targetText style should be given priority.
  /// If there are two targets with same substring, then the higher
  ///  lower priority target style will be overridden by the higher
  ///  priority target style.
  ///
  /// e.g. If there are two targets 'ant' and 'pant'. As word `Pantry`, contains
  /// 'ant' and 'pant', as we see two targets with same substring 'ant'.
  final int priority;
}

class TargetTextHighlights {
  TargetTextHighlights([this.targetHighlights = const <TargetTextHighlight>[]])
      : assert(
          _uniqueTargetTexts(targetHighlights),
          'Each target text should be unique. Duplicate text found: ${_duplicateTargetText(targetHighlights)}.',
        ),
        assert(
          _uniquePriority(targetHighlights),
          'Each target text should have unique priority. Duplicate priority found.',
        );

  final List<TargetTextHighlight> targetHighlights;

  void _sortTargetTextHighlight() {
    targetHighlights.sort((a, b) => b.priority.compareTo(a.priority));
  }

  bool get isEmpty => targetHighlights.isEmpty;

  TargetTextHighlight? getPriorityTargetTextHighlight() {
    if (targetHighlights.isEmpty) {
      return null;
    }
    _sortTargetTextHighlight();
    return targetHighlights.first;
  }

  static bool _uniqueTargetTexts(
    Iterable<TargetTextHighlight> highlights,
  ) {
    final Set<String> targetTexts = <String>{};
    for (TargetTextHighlight highlight in highlights) {
      if (!targetTexts.add(highlight.targetText)) {
        return false;
      }
    }

    return true;
  }

  static String _duplicateTargetText(
    Iterable<TargetTextHighlight> highlights,
  ) {
    final Set<String> targetTexts = <String>{};
    for (TargetTextHighlight highlight in highlights) {
      if (!targetTexts.add(highlight.targetText)) {
        return highlight.targetText;
      }
    }
    return '';
  }

  static bool _uniquePriority(
    Iterable<TargetTextHighlight> highlights,
  ) {
    final Set<int> priorities = <int>{};
    for (TargetTextHighlight highlight in highlights) {
      priorities.add(highlight.priority);
    }
    return priorities.length == highlights.length;
  }
}
