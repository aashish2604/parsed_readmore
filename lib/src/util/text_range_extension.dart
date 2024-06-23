import 'dart:ui';

extension TextRangeExtension on TextRange {
  /// The indexes of the range. For example:
  /// ```dart
  /// TextRange(start: 3, end: 5).rangeIndexes() // [3, 4]
  /// TextRange(start: 7, end: 10).rangeIndexes() // [7, 8, 9]
  /// ```
  Iterable<int> rangeIndexes() sync* {
    for (int i = start; i < end; i++) {
      yield i;
    }
  }
}

extension TextRangeIterableExtension on Iterable<int> {
  List<TextRange> toTextRanges() {
    if (isEmpty) return [];

    final ranges = <TextRange>[];
    final sortedIndexes = toList()..sort();

    var start = sortedIndexes.first;
    var end = start;

    for (var i = 1; i < sortedIndexes.length; i++) {
      if (sortedIndexes[i] == end + 1) {
        end = sortedIndexes[i];
      } else {
        ranges.add(TextRange(start: start, end: end + 1));
        start = sortedIndexes[i];
        end = start;
      }
    }

    // Add the last range
    ranges.add(TextRange(start: start, end: end + 1));

    return ranges;
  }
    /// [validateExpectEndIndexValue] function take the end index which this range is expected to
    /// after locating the range. This function consume that newly located
    /// end index and return the new end index, by doing some checks if they
    /// are valid.
    /// e.g. expectEndIndexValue index is always set to end index + 1
    /// but if the end index is

  TextRange firstTextRangeFromStartIndex(
    int startIndex, {
    int? Function(int expectEndIndexValue)? validateExpectEndIndexValue,
    bool Function(int current, int next)? checkIsRangeValid,
  }) {
    // if start index and contains then throw error
    if (!contains(startIndex)) {
      throw Exception('startIndex $startIndex is not in the list');
    }

    if (length == 1 && first == startIndex) {
      return TextRange(start: startIndex, end: startIndex + 1);
    }

    final sortedIndexes = toList()..sort();

    final start = startIndex;
    int end = start;

    for (var i = sortedIndexes.indexOf(start); i < length - 1; i++) {
      final indexValue = sortedIndexes[i];
      final nextIndexValue = sortedIndexes[i + 1];

      if (indexValue + 1 != nextIndexValue) {
        break;
      }

      if (checkIsRangeValid != null &&
          !checkIsRangeValid.call(indexValue, nextIndexValue)) {
        break;
      }

      end = nextIndexValue;
    }
    final expectEndIndexValue = end + 1;
    return TextRange(
      start: start,
      end: validateExpectEndIndexValue?.call(expectEndIndexValue) ??
          expectEndIndexValue,
    );
  }
}
