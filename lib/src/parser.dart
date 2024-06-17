import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parsed_readmore/parsed_readmore.dart';
import 'package:parsed_readmore/src/util/colors.dart';
import 'package:parsed_readmore/src/util/regex.dart';
import 'package:url_launcher/url_launcher.dart';

class Parser {
  bool readMore;
  TrimMode trimMode;
  TextStyle? urlTextStyle;
  TextStyle? effectiveTextStyle;
  void Function(String url)? onTapLink;
  List<TargetTextHighlight> highlights;

  Parser({
    required this.readMore,
    required this.trimMode,
    required this.urlTextStyle,
    required this.effectiveTextStyle,
    required this.onTapLink,
    this.highlights = const [],
  });

  // Text Span detection and highlighting function
  List<TextSpan> detectHighlightText(List<TextSpan> textSpans) {
    List<TextSpan> alteredTextSpans = <TextSpan>[];

    for (TextSpan span in textSpans) {
      String? text = span.text;

      if (text != null && highlights.isNotEmpty) {
        List<TextSpan> tempSpans = [span];

        for (TargetTextHighlight highlight in highlights) {
          tempSpans = _applyHighlight(tempSpans, highlight);
        }

        alteredTextSpans.addAll(tempSpans);
      } else {
        alteredTextSpans.add(span);
      }
    }

    return alteredTextSpans;
  }

  List<TextSpan> _applyHighlight(
      List<TextSpan> textSpans, TargetTextHighlight highlight) {
    List<TextSpan> alteredTextSpans = <TextSpan>[];
    RegExp regex = RegExp(
      highlight.targetTextHighlightType == TargetTextHighlightType.word
          ? '\\b${RegExp.escape(highlight.targetText)}\\b'
          : RegExp.escape(highlight.targetText),
      caseSensitive: highlight.caseSensitive,
    );

    for (TextSpan span in textSpans) {
      String? text = span.text;

      if (text != null && regex.hasMatch(text)) {
        Iterable<RegExpMatch> matches = regex.allMatches(text);
        int lastIndex = 0;

        for (RegExpMatch match in matches) {
          // Check if match is part of a URL
          if (highlight.targetTextHighlightType ==
                  TargetTextHighlightType.stringMatch &&
              _isPartOfUrl(text, match.start, match.end)) {
            continue;
          }

          if (match.start > lastIndex) {
            alteredTextSpans.add(TextSpan(
              text: text.substring(lastIndex, match.start),
              style: span.style,
            ));
          }

          String matchedText = text.substring(match.start, match.end);
          final highlightTap = highlight.onTap;
          if (highlightTap != null) {
            alteredTextSpans.add(TextSpan(
              text: matchedText,
              style: highlight.style,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  highlightTap(match.start, match.end, matchedText);
                },
            ));
          } else {
            alteredTextSpans.add(TextSpan(
              text: matchedText,
              style: highlight.style,
            ));
          }

          lastIndex = match.end;
        }

        if (lastIndex < text.length) {
          alteredTextSpans.add(TextSpan(
            text: text.substring(lastIndex),
            style: span.style,
          ));
        }
      } else {
        alteredTextSpans.add(span);
      }
    }

    return alteredTextSpans;
  }

  bool _isPartOfUrl(String text, int start, int end) {
    // Comprehensive URL detection regex
    RegExp urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*',
      caseSensitive: false,
    );
    Iterable<RegExpMatch> urlMatches = urlRegex.allMatches(text);
    for (RegExpMatch urlMatch in urlMatches) {
      if (start >= urlMatch.start && end <= urlMatch.end) {
        return true;
      }
    }
    return false;
  }

  // Function to get the list of substrings on the basis of them being a link or not
  List<TextSpan> getSentenceList(String s,
      [int? limit, bool condition = false]) {
    // int lengthSum = 0;
    final RegExp exp = RegExp(kUrlRegEx);
    final Iterable<RegExpMatch> matches = exp.allMatches(s);
    final Map<int, int> indices = {};
    for (var match in matches) {
      indices[match.start] = match.end;
    }

    final List<String> sentences = [];
    if (indices.isNotEmpty) {
      int flag = 0;
      indices.forEach((key, value) {
        if (flag != key) sentences.add(s.substring(flag, key));
        sentences.add("|~|${s.substring(key, value)}");
        flag = value;
      });
      if (flag != s.length) sentences.add(s.substring(flag));
    } else {
      sentences.add(s);
    }
    List<TextSpan> listOfTextSpans = [];
    bool loopBreak = false;

    for (String val in sentences) {
      if (condition && readMore) {
        if (trimMode == TrimMode.line && val.length > limit!) {
          val = val.substring(0, limit);
          loopBreak = true;
        }

        if (trimMode == TrimMode.length && val.length > limit!) {
          val = val.substring(0, limit);
          loopBreak = true;
        }
      }
      if (loopBreak == false && limit != null) {
        limit = limit - val.length;
      }

      String url = '';
      if (val.length >= 3) {
        if (val.substring(0, 3) == '|~|') {
          if (limit != null) {
            limit = limit + 3;
          }
          url = val.substring(3);

          ///TextSpan if the string of the list is a url
          listOfTextSpans.add(TextSpan(
              text: url,
              style: urlTextStyle ??
                  effectiveTextStyle!.copyWith(
                      color: kAzureRadianceColor,
                      decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (!url.startsWith('http://') &&
                      !url.startsWith('https://')) {
                    url = 'https://$url';
                  }

                  if (onTapLink != null) {
                    onTapLink!.call(url);
                  } else {
                    try {
                      Uri launchUri = Uri.parse(url);
                      launchUrl(launchUri,
                          mode: LaunchMode.externalApplication);
                    } on Exception catch (e) {
                      throw Exception(e);
                    }
                  }
                }));
        } else {
          listOfTextSpans.add(TextSpan(text: val, style: effectiveTextStyle));
        }
      } else {
        listOfTextSpans.add(TextSpan(text: val, style: effectiveTextStyle));
      }
      if (loopBreak) {
        break;
      }
    }
    if (highlights.isNotEmpty) {
      var finalSpans = detectHighlightText(listOfTextSpans);
      return finalSpans;
    } else {
      return listOfTextSpans;
    }
  }
}
