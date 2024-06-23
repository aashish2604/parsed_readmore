import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parsed_readmore/parsed_readmore.dart';
import 'package:parsed_readmore/src/util/colors.dart';

void main() {
  const inputText = 'Visit my website at https://example.com';
  group('TextHighlightParser tests', () {
    group('Instance tests', () {
      const parser = TextHighlightParser(data: inputText);

      test('TextHighlightParser Instance should be created', () {
        expect(
          parser,
          isNotNull,
          reason: 'Instance should not be null',
        );
      });

      test('TextHighlightParser data should be"$inputText"', () {
        expect(
          parser.data,
          inputText,
          reason: 'Expected data to be Visit my website at https://example.com',
        );
      });

      test('TextHighlightParser targetTextHighlights should be null', () {
        expect(
          parser.targetTextHighlights,
          isNull,
          reason: 'Expected targetTextHighlights to be null',
        );
      });

      group(
        'Instance tests with targetTextHighlights',
        () {
          final parser = TextHighlightParser(
            data: inputText,
            targetTextHighlights: TargetTextHighlights(
              [
                const TargetTextHighlight(
                  targetText: 'Visit',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                  priority: 1,
                ),
                const TargetTextHighlight(
                  targetText: 'website',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                  priority: 2,
                ),
              ],
            ),
          );

          test('TextHighlightParser targetTextHighlights should not be null',
              () {
            expect(
              parser.targetTextHighlights,
              isNotNull,
              reason: 'Expected targetTextHighlights to not be null',
            );
          });

          test(
            'TextHighlightParser targetTextHighlights should contain 1 TargetTextHighlight',
            () {
              expect(
                parser.targetTextHighlights?.targetHighlights,
                hasLength(2),
              );
            },
          );

          test(
            'getPriorityTargetTextHighlight method test',
            () {
              final targetTextHighlight =
                  parser.targetTextHighlights?.getPriorityTargetTextHighlight();

              expect(
                targetTextHighlight,
                isNotNull,
                reason:
                    'TargetTextHighlight should not be null. As there are 2 targets.',
              );

              expect(
                targetTextHighlight!.priority,
                2,
                reason:
                    'TargetTextHighlight priority should be 2. As this target is with highest priority.',
              );
            },
          );

          group('findUrlRanges method tests', () {
            final urlRanges = parser.findUrlRanges();

            test('1 Text Range should be created', () {
              expect(
                urlRanges,
                hasLength(1),
              );
            });
            final range = urlRanges.elementAt(0);

            test('Text Range start index should be 20', () {
              expect(
                range.start,
                20,
                reason: 'Expected start index to be 20',
              );
            });

            test('Text Range end index should be 39', () {
              expect(
                range.end,
                39,
                reason: 'Expected end index to be 39',
              );
            });

            test('Text Range text should be" https://example.com"', () {
              expect(
                range.textInside(inputText),
                'https://example.com',
                reason: 'Expected text inside range to be https://example.com',
              );
            });

            test('Text Range text before should be" Visit my website at "', () {
              expect(
                range.textBefore(inputText),
                'Visit my website at ',
                reason: 'Expected text before range to be Visit my website at ',
              );
            });

            test('Text Range text after should be""', () {
              expect(
                range.textAfter(inputText),
                '',
                reason: 'Expected text after range to be empty',
              );
            });
          });
        },
      );
    });
  });

  test('Parser applies default text style to the urls', () {
    const parser = TextHighlightParser(
      data: inputText,
      trimMode: TrimMode.line,
      urlTextStyle: null,
      onTapLink: null,
    );
    final allTextHighlights = parser.findTextHighlights();

    final result = parser.getSentenceList(
      maxShowCharactersLength: parser.data.length,
      effectiveTextStyle: const TextStyle(),
      allTextHighlights: parser.findTextHighlights(),
      allUrlRanges: parser.findUrlRanges(),
      allIndexTargetTextHighlightsMap:
          TextHighlightParser.createIndexTargetTextHighlightsMap(
        allTextHighlights,
      ),
      trackActiveTapGesture: (_) {},
    );

    expect(result, hasLength(2));
    expect(
        result[1].style,
        const TextStyle(
          color: kAzureRadianceColor,
          decoration: TextDecoration.underline,
        ));
  });

  test('Parser applies custom text style to the urls', () {
    final parser = TextHighlightParser(
      data: inputText,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(fontSize: 16, color: Colors.green),
      onTapLink: (url) {},
    );

    final allTextHighlights = parser.findTextHighlights();

    final result = parser.getSentenceList(
      maxShowCharactersLength: parser.data.length,
      effectiveTextStyle: const TextStyle(),
      allTextHighlights: parser.findTextHighlights(),
      allUrlRanges: parser.findUrlRanges(),
      allIndexTargetTextHighlightsMap:
          TextHighlightParser.createIndexTargetTextHighlightsMap(
        allTextHighlights,
      ),
      trackActiveTapGesture: (_) {},
    );

    expect(result, hasLength(2));
    expect(result[0].text, 'Visit my website at ');
    expect(result[1].style, const TextStyle(fontSize: 16, color: Colors.green));
  });

  test('Parser handles non-link text', () {
    const inputText = 'This is a regular text.';
    final parser = TextHighlightParser(
      data: inputText,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(),
      onTapLink: (url) {},
    );

    final allTextHighlights = parser.findTextHighlights();

    final result = parser.getSentenceList(
      maxShowCharactersLength: parser.data.length,
      effectiveTextStyle: const TextStyle(),
      allTextHighlights: parser.findTextHighlights(),
      allUrlRanges: parser.findUrlRanges(),
      allIndexTargetTextHighlightsMap:
          TextHighlightParser.createIndexTargetTextHighlightsMap(
        allTextHighlights,
      ),
      trackActiveTapGesture: (_) {},
    );

    expect(result, hasLength(1));
    expect(result[0].text, inputText);
  });

  test('Parser detects and highlights custom target text', () {
    
    const inputText = 'Visit my example website at a website.com';
    final parser = TextHighlightParser(
      data: inputText,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(),
      onTapLink: (url) {},
      targetTextHighlights: TargetTextHighlights([
        const TargetTextHighlight(
          targetText: 'example',
          priority: 1,
          style: TextStyle(color: Colors.red),
        )
      ]),
    );

    final allTextHighlights = parser.findTextHighlights();

    final result = parser.getSentenceList(
      maxShowCharactersLength: parser.data.length,
      effectiveTextStyle: const TextStyle(),
      allTextHighlights: parser.findTextHighlights(),
      allUrlRanges: parser.findUrlRanges(),
      allIndexTargetTextHighlightsMap:
          TextHighlightParser.createIndexTargetTextHighlightsMap(
        allTextHighlights,
      ),
      trackActiveTapGesture: (_) {},
    );
    expect(result, hasLength(4));
    expect(result[1].text, 'example');
    expect(result[1].style?.color, Colors.red);
  });
}
