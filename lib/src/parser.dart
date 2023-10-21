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
  TargetTextHighlight? highlightText;

  Parser(
      {required this.readMore,
      required this.trimMode,
      required this.urlTextStyle,
      required this.effectiveTextStyle,
      required this.onTapLink,
      required this.highlightText});

  // Function to get the occurances of string in the spans
  List<int> findWordOccurrences(String text, String word) {
    List<int> occurrences = [];
    int index = 0;

    while (index != -1) {
      index = text.toLowerCase().indexOf(word.toLowerCase(), index);

      if (index != -1) {
        occurrences.add(index);
        index += word.length;
      }
    }

    return occurrences;
  }

  // Text Span detection and highlighting function
  List<TextSpan> detectHighlightText(List<TextSpan> textSpans) {
    List<TextSpan> alteredTextSpans = <TextSpan>[];
    int k = 0;
    for (int i = 0; i < textSpans.length; i++) {
      TextSpan span = textSpans[i];
      String? text = span.text;

      if (text != null && highlightText != null) {
        if (text.length >= 3) {
          String? substr = text.substring(0, 3);
          List<int> firstInd = <int>[];
          if (substr != '|~|' && text.contains(highlightText!.targetText)) {
            firstInd = findWordOccurrences(text, highlightText!.targetText);
            if (firstInd[0] > 0) {
              alteredTextSpans.insert(
                  k,
                  TextSpan(
                      text: text.substring(0, firstInd[0]),
                      style: effectiveTextStyle));
            } else {
              k--;
            }
            for (int j = 0; j < firstInd.length; j++) {
              k++;
              int s = highlightText!.targetText.length;
              alteredTextSpans.insert(
                  k,
                  TextSpan(
                      text: text.substring(firstInd[j], firstInd[j] + s),
                      style: highlightText!.style));
              k++;
              if (j == firstInd.length - 1) {
                alteredTextSpans.insert(
                    k,
                    TextSpan(
                        text: text.substring(firstInd[j] + s),
                        style: effectiveTextStyle));
              } else {
                alteredTextSpans.insert(
                    k,
                    TextSpan(
                        text: text.substring(firstInd[j] + s, firstInd[j + 1]),
                        style: effectiveTextStyle));
              }
            }
            k++;
          } else {
            alteredTextSpans.insert(k, textSpans[i]);
            k++;
          }
        } else {
          alteredTextSpans.insert(k, textSpans[i]);
          k++;
        }
      }
    }
    return alteredTextSpans;
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
    if (highlightText != null) {
      var finalSpans = detectHighlightText(listOfTextSpans);
      return finalSpans;
    } else {
      return listOfTextSpans;
    }
  }
}
