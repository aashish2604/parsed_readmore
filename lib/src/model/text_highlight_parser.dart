import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parsed_readmore/parsed_readmore.dart';
import 'package:parsed_readmore/src/util/colors.dart';
import 'package:parsed_readmore/src/util/list_extension.dart';
import 'package:parsed_readmore/src/util/regex.dart';
import 'package:parsed_readmore/src/util/text_range_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class TextHighlightParser {
  const TextHighlightParser({
    required this.data,
    this.targetTextHighlights,
    this.onTapLink,
    this.urlTextStyle,
    this.initialState = ReadMoreState.collapsed,
    this.trimMode = TrimMode.character,
    this.maxCharacters = 240,
    this.maxLines = 2,
  })  : assert(maxLines > 0, 'trimLines must be greater than 0'),
        assert(maxCharacters > 0, 'trimLength must be greater than 0');

  /// Initial state of the widget when it is created.
  /// [ReadMoreState.collapsed] by default
  final ReadMoreState initialState;

  /// The text to be parsed
  final String data;

  /// The target text highlights
  final TargetTextHighlights? targetTextHighlights;

  /// A function called when a link is clicked. The url should start with http:// or https://.
  /// If the url doesn't start with http:// or https://, or if [onTapLink] is null the link will open
  /// on the external browser.
  final void Function(String url)? onTapLink;

  /// The url style for the link
  final TextStyle? urlTextStyle;

  /// Used when [trimMode] is [TrimMode.characters]
  /// By default, it is 240
  final int maxCharacters;

  /// Used when [trimMode] is [TrimMode.lines]
  /// By default, it is 2
  final int maxLines;

  /// Determines the type of trim. [TrimMode.characters] takes into account
  /// the number of characters, while [TrimMode.lines] takes into account
  /// the number of lines and [TrimMode.none] will show the as many
  /// characters  as possible in the widget layout.
  /// By default, it is [TrimMode.character]
  final TrimMode trimMode;

  Iterable<TextRange> findUrlRanges() sync* {
    final urlRegex = RegExp(kUrlRegEx);

    final matches = urlRegex.allMatches(data);

    for (final match in matches) {
      yield TextRange(start: match.start, end: match.end);
    }
  }

  List<TextHighlight> findTextHighlights() {
    final patternMatches = <TextHighlight>[];
    final targetHighlights = targetTextHighlights?.targetHighlights;
    if (targetHighlights == null) {
      return patternMatches;
    }

    for (final targetHighlight in targetHighlights) {
      final regExp = RegExp(targetHighlight.targetText,
          caseSensitive: targetHighlight.caseSensitive);
      final matches = regExp.allMatches(data);

      var textHighlight = TextHighlight(targetHighlight: targetHighlight);

      for (final match in matches) {
        textHighlight = textHighlight.copyWith(
          highlightRanges: {
            ...textHighlight.highlightRanges,
            TextRange(start: match.start, end: match.end)
          },
        );
      }
      patternMatches.add(textHighlight);
    }

    return patternMatches;
  }

  List<TextSpan> getSentenceList({
    required int maxShowCharactersLength,
    required TextStyle effectiveTextStyle,
    required List<TextHighlight> allTextHighlights,
    required Iterable<TextRange> allUrlRanges,
    required Map<int, TargetTextHighlights> allIndexTargetTextHighlightsMap,
    required void Function(TapGestureRecognizer recognizer)
        trackActiveTapGesture,
  }) {
    final allIndexes = Set<int>.unmodifiable(
      Iterable<int>.generate(maxShowCharactersLength + 1),
    );
    final textHighlights = allTextHighlights
        .where((textHighlight) => textHighlight.highlightRanges.any(
              (range) => allIndexes.containsAll(range.rangeIndexes()),
            ))
        .toList();

    final urlRanges =
        allUrlRanges.where((range) => range.start < maxShowCharactersLength);

    final textHighlightRangesIndexes = Set<int>.unmodifiable(
        textHighlights.expand((textHighlight) => textHighlight.highlightRanges
            .map((range) => range.rangeIndexes())
            .expand((i) => i)));

    final urlHighlightIndexes = Set<int>.from(urlRanges.expand(
      (range) => range.rangeIndexes(),
    ));

    // We have to remove the index which are greater than endIndex.
    // As while creating urlRanges we check if start index is greater than
    // endIndex. And we do that because [_createUrlTextSpan] method takes
    // highlightText and fullUrl as parameter. So to get the fullUrl we
    // need to check if start index is greater than endIndex. Which means
    // even if the highlight portion of the url is trimmed, we need to
    // make sure that even if user click on the highlight portion,
    //  click should work. But by removing below we make sure that
    // while displaying the trimmed version we don't show any unwanted portion.
    urlHighlightIndexes.removeWhere((i) => i > maxShowCharactersLength);

    final allHighlightIndexesSet =
        textHighlightRangesIndexes.union(urlHighlightIndexes);

    final allHighlightIndexes = allHighlightIndexesSet.toList()..sort();
    final nonHighlightIndexes =
        allIndexes.difference(allHighlightIndexesSet).toList()..sort();
    final textSpans = <TextSpan>[];

    for (var i = 0; i < maxShowCharactersLength + 1; i++) {
      // We have -1 as end index is also increased by 1, and when next time
      // the loop is execute it will be increase by one as [i++]. So,
      // we need to decrease it by 1 to normalize it.
      final indexValue = allIndexes.elementAt(i == 0 ? 0 : i - 1);

      if (nonHighlightIndexes.contains(indexValue)) {
        final nonHighlightRange =
            nonHighlightIndexes.firstTextRangeFromStartIndex(
          indexValue,
          validateExpectEndIndexValue: (expectEndIndexValue) {
            if (allIndexes.contains(expectEndIndexValue)) {
              return expectEndIndexValue;
            }
            return allIndexes.last;
          },
        );

        final text = nonHighlightRange.textInside(data);
        textSpans.add(
          TextSpan(
            text: text,
            style: effectiveTextStyle,
          ),
        );

        i = nonHighlightRange.end;
        continue;
      }

      final highlightRange = allHighlightIndexes.firstTextRangeFromStartIndex(
        indexValue,
        validateExpectEndIndexValue: (expectEndIndexValue) {
          if (allIndexes.contains(expectEndIndexValue)) {
            return expectEndIndexValue;
          }
          return allIndexes.last;
        },
      );

      final highlightRangeIndexes = highlightRange.rangeIndexes().toSet();

      final urlRange = allUrlRanges.firstWhereOrNull(
        (urlRange) =>
            highlightRangeIndexes.containsAll(urlRange.rangeIndexes()),
      );

      if (urlRange != null) {
        final fullUrl = urlRange.textInside(data);
        var url = fullUrl;

        final urlRangeIndexes = urlRange.rangeIndexes().toSet();
        final targetSubStringHighlightIndexes =
            textHighlightRangesIndexes.intersection(urlRangeIndexes);
        onTapLinkCallback() async {
          if (!url.startsWith('http://') && !url.startsWith('https://')) {
            url = 'https://$fullUrl';
          }

          onTapLink?.call(fullUrl);
          if (onTapLink != null) {
          } else {
            try {
              final launchUri = Uri.parse(url);
              await launchUrl(launchUri, mode: LaunchMode.externalApplication);
            } on Exception catch (e) {
              throw Exception(e);
            }
          }
        }

        final urlChildren = _urlSubStringHighlightTextSpans(
          urlRangeIndexes: urlRangeIndexes,
          targetSubStringHighlightIndexes: targetSubStringHighlightIndexes,
          effectiveTextStyle: effectiveTextStyle,
          overrideOnTap: (_) {
            onTapLinkCallback();
          },
          shouldApplyHighlight: (targetHighlight) {
            return targetHighlight.highlightInUrl;
          },
          allIndexTargetTextHighlightsMap: allIndexTargetTextHighlightsMap,
          trackActiveTapGesture: trackActiveTapGesture,
        );

        final firstHighlightSubstring = urlChildren.isEmpty
            ? fullUrl
            : targetSubStringHighlightIndexes.contains(urlRange.start)
                ? targetSubStringHighlightIndexes
                    .firstTextRangeFromStartIndex(urlRange.start)
                    .textInside(data)
                : null;

        textSpans.add(
          _createUrlTextSpan(
            firstHighlightSubstring: firstHighlightSubstring,
            fullUrl: fullUrl,
            children: urlChildren,
            effectiveTextStyle: effectiveTextStyle,
            onTapLinkCallback: onTapLinkCallback,
          ),
        );
      } else {
        final highlightTextSpans = _highlightTextSpans(
          highlightRange: highlightRange,
          highlightRangeIndexes: highlightRangeIndexes,
          effectiveTextStyle: effectiveTextStyle,
          allIndexTargetTextHighlightsMap: allIndexTargetTextHighlightsMap,
          trackActiveTapGesture: trackActiveTapGesture,
        );
        textSpans.addAll(highlightTextSpans);
      }

      i = highlightRange.end;
    }

    return textSpans;
  }

  TextSpan _createUrlTextSpan({
    String? firstHighlightSubstring,
    List<TextSpan>? children,
    // We have two variables here, as it is possible that in some case
    // the portion of the url text is highlight and then remaining
    // portion is trimmed. So, in such case, we need to make sure that
    // even if user click on the highlight portion, click should work.
    required String fullUrl,
    required TextStyle effectiveTextStyle,
    required void Function() onTapLinkCallback,
  }) {
    return TextSpan(
      text: firstHighlightSubstring,
      children: children,
      style: urlTextStyle ??
          effectiveTextStyle.copyWith(
            color: kAzureRadianceColor,
            decoration: TextDecoration.underline,
          ),
      recognizer: TapGestureRecognizer()..onTap = onTapLinkCallback,
    );
  }

  List<TextSpan> _urlSubStringHighlightTextSpans({
    required Set<int> urlRangeIndexes,
    required Set<int> targetSubStringHighlightIndexes,
    required TextStyle effectiveTextStyle,
    required Map<int, TargetTextHighlights> allIndexTargetTextHighlightsMap,
    required bool Function(TargetTextHighlight) shouldApplyHighlight,
    required void Function(TapGestureRecognizer recognizer)
        trackActiveTapGesture,
    void Function(TextRange)? overrideOnTap,
  }) {
    if (targetSubStringHighlightIndexes.isEmpty) {
      return [];
    }

    final indexTargetTextHighlightsMap =
        _getIndexTargetTextHighlightPriorityMap(
      targetSubStringHighlightIndexes,
      shouldApplyHighlight: shouldApplyHighlight,
      allIndexTargetTextHighlightsMap: allIndexTargetTextHighlightsMap,
    );

    if (indexTargetTextHighlightsMap.isEmpty) {
      return [];
    }

    return _applyHighlightTextSpans(
      indexTargetTextHighlightsMap: indexTargetTextHighlightsMap,
      highlightRangeIndexes: urlRangeIndexes,
      effectiveTextStyle: effectiveTextStyle,
      overrideOnTap: overrideOnTap,
      trackActiveTapGesture: trackActiveTapGesture,
    );
  }

  List<TextSpan> _highlightTextSpans({
    required TextRange highlightRange,
    required Set<int> highlightRangeIndexes,
    required TextStyle effectiveTextStyle,
    required Map<int, TargetTextHighlights> allIndexTargetTextHighlightsMap,
    required void Function(TapGestureRecognizer recognizer)
        trackActiveTapGesture,
  }) {
    final indexTargetTextHighlightsMap =
        _getIndexTargetTextHighlightPriorityMap(
      highlightRangeIndexes,
      allIndexTargetTextHighlightsMap: allIndexTargetTextHighlightsMap,
    );
    if (indexTargetTextHighlightsMap.isEmpty) {
      final text = highlightRange.textInside(data);
      return [TextSpan(text: text, style: effectiveTextStyle)];
    }

    return _applyHighlightTextSpans(
      indexTargetTextHighlightsMap: indexTargetTextHighlightsMap,
      highlightRangeIndexes: highlightRangeIndexes,
      effectiveTextStyle: effectiveTextStyle,
      trackActiveTapGesture: trackActiveTapGesture,
    );
  }

  List<TextSpan> _applyHighlightTextSpans({
    required Map<int, TargetTextHighlight> indexTargetTextHighlightsMap,
    required Set<int> highlightRangeIndexes,
    required TextStyle effectiveTextStyle,
    // The below function is used to track active tap gesture
    // so that when the widget is disposed, the active tap gesture
    // is cancelled.
    required void Function(TapGestureRecognizer recognizer)
        trackActiveTapGesture,
    void Function(TextRange)? overrideOnTap,
  }) {
    final highlightTextSpans = <TextSpan>[];
    final indexes = highlightRangeIndexes.toList()..sort();
    final highlightRangeIndexesSet = indexTargetTextHighlightsMap.keys.toSet();
    final nonHighlightRangeIndexes = highlightRangeIndexes
        .toSet()
        .difference(highlightRangeIndexesSet)
        .toList()
      ..sort();

    for (var i = 0; i < indexes.length; i++) {
      final indexValue = indexes.elementAt(i);

      final targetHighlight = highlightRangeIndexesSet.contains(indexValue)
          ? indexTargetTextHighlightsMap[indexValue]
          : null;
      if (targetHighlight == null) {
        final nonHighlightRange =
            nonHighlightRangeIndexes.firstTextRangeFromStartIndex(indexValue);
        final text = nonHighlightRange.textInside(data);
        highlightTextSpans.add(
          TextSpan(
            text: text,
            style: urlTextStyle ?? effectiveTextStyle,
          ),
        );
        // We have -1 as end index is also increased by 1, and when next time
        // the loop is execute it will be increase by one as [i++]. So,
        // we need to decrease it by 1.
        i = indexes.indexOf(nonHighlightRange.end - 1);
        continue;
      }

      final highlightRange = _textRangeForSubStringHighlight(
        startIndexValue: indexValue,
        indexTargetTextHighlightsMap: indexTargetTextHighlightsMap,
      );
      final text = highlightRange.textInside(data);
      final onTap = overrideOnTap ?? targetHighlight.onTap;
      if (onTap != null) {
        final recognizer = TapGestureRecognizer()
          ..onTap = () => onTap(highlightRange);

        highlightTextSpans.add(
          TextSpan(
            text: text,
            style: targetHighlight.style,
            recognizer: recognizer,
          ),
        );
        trackActiveTapGesture(recognizer);
      } else {
        highlightTextSpans
            .add(TextSpan(text: text, style: targetHighlight.style));
      }

      // We have -1 as end index is also increased by 1, and when next time
      // the loop is execute it will be increase by one as [i++]. So,
      // we need to decrease it by 1.
      i = indexes.indexOf(highlightRange.end - 1);
    }

    return highlightTextSpans;
  }

  Map<int, TargetTextHighlight> _getIndexTargetTextHighlightPriorityMap(
    Set<int> targetSubStringHighlightIndexes, {
    required Map<int, TargetTextHighlights> allIndexTargetTextHighlightsMap,
    bool Function(TargetTextHighlight)? shouldApplyHighlight,
  }) {
    final indexTargetTextHighlightsMap = <int, TargetTextHighlight>{};

    for (var i = 0; i < targetSubStringHighlightIndexes.length; i++) {
      final indexValue = targetSubStringHighlightIndexes.elementAt(i);
      final targetHighlight = allIndexTargetTextHighlightsMap[indexValue]
          ?.getPriorityTargetTextHighlight();

      if (targetHighlight == null) {
        continue;
      }

      if (shouldApplyHighlight != null &&
          !shouldApplyHighlight.call(targetHighlight)) {
        continue;
      }

      indexTargetTextHighlightsMap[indexValue] = targetHighlight;
    }

    return indexTargetTextHighlightsMap;
  }

  // TextRange for substring text highlight. If the range of
  // indexes have same target highlight meaning same priority.
  TextRange _textRangeForSubStringHighlight({
    required int startIndexValue,
    required Map<int, TargetTextHighlight> indexTargetTextHighlightsMap,
  }) {
    final sortIndexes = indexTargetTextHighlightsMap.keys.toList()..sort();

    return sortIndexes.firstTextRangeFromStartIndex(startIndexValue,
        checkIsRangeValid: (current, next) {
      final indexTargetHighlight = indexTargetTextHighlightsMap[current];
      final nextIndexTargetHighlight = indexTargetTextHighlightsMap[next];

      if (indexTargetHighlight == null || nextIndexTargetHighlight == null) {
        return false;
      }

      if (indexTargetHighlight.priority != nextIndexTargetHighlight.priority) {
        return false;
      }
      return true;
    });
  }

  int maxCharactersToShow({
    required TextSpan dataTextSpan,
    required TextSpan suffixTextSpan,
    required TextPainter textPainter,
    required bool shouldShowSuffixText,
    required BoxConstraints constraints,
    required ReadMoreState readMoreState,
    required bool shouldShowReadMoreText,
    required bool shouldShowReadLessText,
    required TextSpan expandCollapseTextSpan,
    required TextSpan readMoreDelimiterTextSpan,
    required TextSpan readLessDelimiterTextSpan,
  }) {
    final isTimeModeLines = trimMode == TrimMode.line;
    final isTimeModeCharacters = trimMode == TrimMode.character;
    final isCollapsedState = readMoreState == ReadMoreState.collapsed;
    final isExpandedState = readMoreState == ReadMoreState.expanded;
    final maxWidth = constraints.maxWidth;
    final minWidth = constraints.minWidth;

    // Max index that can be visible in the available box-constraints
    var maxVisibleCharacterLength = 0;
    // Max index to show based on given trimMode
    var maxCharacterLengthToShow = 0;

    // Layout and measure expandCollapseTextSize
    textPainter.text = expandCollapseTextSpan;
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final expandCollapseTextSize = textPainter.size;

    // Layout and measure readMoreDelimiterSize
    textPainter.text = readMoreDelimiterTextSpan;
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final readMoreDelimiterSize = textPainter.size;

    // Layout and measure readLessDelimiterTextSpan
    textPainter.text = readLessDelimiterTextSpan;
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final readLessDelimiterSize = textPainter.size;

    // Layout and measure suffixTextSize
    textPainter.text = suffixTextSpan;
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final suffixTextSize = textPainter.size;

    // Layout and measure textSize
    textPainter.text = dataTextSpan;
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth);
    final dataTextSize = textPainter.size;

    var extraWidth = isCollapsedState && shouldShowReadMoreText
        ? expandCollapseTextSize.width + readMoreDelimiterSize.width
        : isExpandedState && shouldShowReadMoreText
            ? expandCollapseTextSize.width + readLessDelimiterSize.width
            : 0;
    if (shouldShowSuffixText) {
      extraWidth += suffixTextSize.width;
    }
    if (dataTextSize.width > maxWidth) {
      final position = textPainter.getPositionForOffset(
        Offset(maxWidth - extraWidth, dataTextSize.height),
      );
      maxVisibleCharacterLength =
          textPainter.getOffsetBefore(position.offset) ?? 0;
    } else {
      maxVisibleCharacterLength = data.length;
    }

    if (isTimeModeLines) {
      switch (readMoreState) {
        case ReadMoreState.collapsed:
          if (textPainter.didExceedMaxLines) {
            final remainingWidth = maxWidth - extraWidth;
            final position = textPainter.getPositionForOffset(
              Offset(remainingWidth, dataTextSize.height),
            );
            maxCharacterLengthToShow =
                textPainter.getOffsetBefore(position.offset) ?? 0;
          } else {
            maxCharacterLengthToShow = maxVisibleCharacterLength;
          }
          break;
        case ReadMoreState.expanded:
          maxCharacterLengthToShow = maxVisibleCharacterLength;
          break;
      }
    }

    if (isTimeModeCharacters) {
      switch (readMoreState) {
        case ReadMoreState.collapsed:
          maxCharacterLengthToShow = maxCharacters;
          break;
        case ReadMoreState.expanded:
          maxCharacterLengthToShow = maxVisibleCharacterLength;
          break;
      }
    }

    switch (trimMode) {
      case TrimMode.character:
        return maxCharacterLengthToShow;

      case TrimMode.line:
        return maxCharacterLengthToShow;
    }
  }

  static Map<int, TargetTextHighlights> createIndexTargetTextHighlightsMap(
      List<TextHighlight> textHighlights) {
    final targetTextHighlightsMap = <int, TargetTextHighlights>{};

    for (final textHighlight in textHighlights) {
      final indexes = textHighlight.highlightRanges
          .expand((textRange) => textRange.rangeIndexes());
      for (var i = 0; i < indexes.length; i++) {
        final indexValue = indexes.elementAt(i);
        final targetHighlights =
            targetTextHighlightsMap[indexValue]?.targetHighlights ?? [];
        targetHighlights.add(textHighlight.targetHighlight);
        targetTextHighlightsMap[indexValue] =
            TargetTextHighlights(targetHighlights);
      }
    }

    return targetTextHighlightsMap;
  }
}
