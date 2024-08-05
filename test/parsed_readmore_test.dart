import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parsed_readmore/parsed_readmore.dart';
import 'package:parsed_readmore/src/parser.dart';
import 'package:parsed_readmore/src/util/colors.dart';
import 'package:parsed_readmore/src/util/regex.dart';

void main() {
  test('Parser can be created', () {
    final parser = Parser(
      readMore: true,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(),
      effectiveTextStyle: const TextStyle(),
      onTapLink: (url) {},
      highlightText: null,
      urlRegex: kUrlRegEx,
    );
    expect(parser, isNotNull);
  });

  test('Parser detects links in text', () {
    final parser = Parser(
      readMore: true,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(),
      effectiveTextStyle: const TextStyle(),
      onTapLink: (url) {},
      highlightText: null,
      urlRegex: kUrlRegEx,
    );

    const inputText = 'Visit my website at https://example.com';
    final result = parser.getSentenceList(inputText);

    expect(result, hasLength(2));
    expect(result[0].text, 'Visit my website at ');
  });

  test('Parser applies default text style to the urls', () {
    final parser = Parser(
      readMore: true,
      trimMode: TrimMode.line,
      urlTextStyle: null,
      effectiveTextStyle: const TextStyle(),
      onTapLink: null,
      highlightText: null,
      urlRegex: kUrlRegEx,
    );

    const inputText = 'Visit my website at https://example.com';
    final result = parser.getSentenceList(inputText);

    expect(result, hasLength(2));
    expect(
        result[1].style,
        const TextStyle(
            color: kAzureRadianceColor, decoration: TextDecoration.underline));
  });

  test('Parser applies custom text style to the urls', () {
    final parser = Parser(
      readMore: true,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(fontSize: 16, color: Colors.green),
      effectiveTextStyle: const TextStyle(),
      onTapLink: (url) {},
      highlightText: null,
      urlRegex: kUrlRegEx,
    );

    const inputText = 'Visit my website at https://example.com';
    final result = parser.getSentenceList(inputText);

    expect(result, hasLength(2));
    expect(result[0].text, 'Visit my website at ');
    expect(result[1].style, const TextStyle(fontSize: 16, color: Colors.green));
  });

  test('Parser handles non-link text', () {
    final parser = Parser(
      readMore: true,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(),
      effectiveTextStyle: const TextStyle(),
      onTapLink: (url) {},
      highlightText: null,
      urlRegex: kUrlRegEx,
    );

    const inputText = 'This is a regular text.';
    final result = parser.getSentenceList(inputText);

    expect(result, hasLength(1));
    expect(result[0].text, inputText);
  });

  test('Parser detects and highlights custom target text', () {
    final parser = Parser(
      readMore: true,
      trimMode: TrimMode.line,
      urlTextStyle: const TextStyle(),
      effectiveTextStyle: const TextStyle(),
      onTapLink: (url) {},
      highlightText: TargetTextHighlight(
          targetText: 'example', style: const TextStyle(color: Colors.red)),
      urlRegex: kUrlRegEx,
    );

    const inputText = 'Visit my example website at a website.com';
    final result = parser.getSentenceList(inputText);

    expect(result, hasLength(4));
    expect(result[1].text, 'example');
    expect(result[1].style?.color, Colors.red);
  });
}
