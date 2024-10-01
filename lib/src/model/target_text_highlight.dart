import 'package:flutter/material.dart';

class TargetTextHighlight {
  const TargetTextHighlight({
    required this.targetText,
    this.priority,
    this.style,
    this.onTap,
    this.caseSensitive = false,
    this.highlightInUrl = false,
  }) : assert(
          (priority == null && style == null) ||
              (priority != null && style != null),
          'priority and style must both be null or both be non-null.',
        );

  /// The regex pattern to match the target text
  final String targetText;

  /// Callback function to be called when the highlight text is clicked
  final void Function(TextRange range)? onTap;

  /// If the pattern is found with-in a URL, below boolean let user set if
  /// the pattern in the URL should be highlighted or not
  final bool highlightInUrl;

  /// if case sensitive is true
  final bool caseSensitive;

  /// User defined text style for the specific target
  final TextStyle? style;

  /// Which targetText style should be given priority.
  /// If there are two targets with same substring, then the higher
  ///  lower priority target style will be overridden by the higher
  ///  priority target style.
  ///
  /// e.g. If there are two targets 'ant' and 'pant'. As word `Pantry`, contains
  /// 'ant' and 'pant', as we see two targets with same substring 'ant'.
  final int? priority;
}

class TargetTextHighlights {
  TargetTextHighlights({
    this.targetHighlights = const <TargetTextHighlight>[],
    this.defaultHighlightStyle,
  })  : assert(
          _uniqueTargetTexts(targetHighlights),
          'Each target text should be unique. Duplicate text found: ${_duplicateTargetText(targetHighlights)}.',
        ),
        assert(
          _uniquePriority(targetHighlights),
          'Each target text should have unique priority. Duplicate priority found.',
        );

  final List<TargetTextHighlight> targetHighlights;

  /// Default text style to be applied when multiple highlights share the same
  /// style. Instead of passing the same style redundantly for
  /// individual highlights, you can specify it here as a fallback.
  final TextStyle? defaultHighlightStyle;

  void _sortTargetTextHighlight() {
    targetHighlights.sort((a, b) {
      final aPriority = a.priority;
      final bPriority = b.priority;
      if (aPriority == null && bPriority == null) {
        return 0;
      }

      if (aPriority == null) {
        return 1;
      }

      if (bPriority == null) {
        return -1;
      }
      return bPriority.compareTo(aPriority);
    });
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

    for (final highlight in highlights) {
      if (!targetTexts.add(highlight.targetText)) {
        // If adding the target text to the set returns false, it means the 
        // target text was already in the set
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
    int nonNullPriorityCount = 0;

    for (TargetTextHighlight highlight in highlights) {
      final priority = highlight.priority;
      if (priority == null) {
        continue;
      }
      if (!priorities.add(priority)) {
        // If adding the priority to the set returns false,
        // it means the priority was already in the set
        return false;
      }
      nonNullPriorityCount++;
    }
    // Ensure the number of unique non-null priorities matches
    //the number of non-null priority highlights
    return priorities.length == nonNullPriorityCount;
  }
}
