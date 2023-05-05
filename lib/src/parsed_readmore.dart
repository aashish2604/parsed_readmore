import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parsed_readmore/src/util/colors.dart';
import 'package:parsed_readmore/src/util/regex.dart';
import 'package:url_launcher/url_launcher.dart';

enum TrimMode {
  length,
  line,
}

class ParsedReadMore extends StatefulWidget {
  const ParsedReadMore(
    this.data, {
    Key? key,
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.colorClickableText,
    this.trimLength = 240,
    this.trimLines = 2,
    this.trimMode = TrimMode.length,
    this.urlTextStyle,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.delimiter = ' $_kEllipsis',
    this.delimiterStyle,
    this.callback,
    this.onTapLink,
  }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  /// TextStyle for expanded text
  final TextStyle? moreStyle;

  /// TextStyle for compressed text
  final TextStyle? lessStyle;

  ///Called when state change between expanded/compress
  final void Function(bool val)? callback;

  final void Function(String url)? onTapLink;

  final String delimiter;
  final TextStyle? urlTextStyle;
  final String data;
  final String trimExpandedText;
  final String trimCollapsedText;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final TextStyle? delimiterStyle;

  @override
  ParsedReadMoreState createState() => ParsedReadMoreState();
}

const String _kEllipsis = '\u2026';

class ParsedReadMoreState extends State<ParsedReadMore> {
  bool _readMore = true;

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      widget.callback?.call(_readMore);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style ?? const TextStyle(color: Colors.black);
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign = widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final textScaleFactor = widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);
    final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final colorClickableText = widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final defaultLessStyle = widget.lessStyle ?? effectiveTextStyle.copyWith(color: colorClickableText);
    final defaultMoreStyle = widget.moreStyle ?? effectiveTextStyle.copyWith(color: colorClickableText);
    final defaultDelimiterStyle = widget.delimiterStyle ?? defaultMoreStyle;

    final TextSpan link = TextSpan(
      text: _readMore ? widget.trimCollapsedText : widget.trimExpandedText,
      style: _readMore ? defaultMoreStyle : defaultLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    final TextSpan delimiter = TextSpan(
      text: _readMore
          ? widget.trimCollapsedText.isNotEmpty
              ? widget.delimiter
              : ''
          : widget.trimExpandedText.isNotEmpty
              ? widget.delimiter
              : '',
      style: defaultDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    ///Function to get the list of substrings on the basis of them being a link or not
    List<TextSpan> getSentenceList(String s, [int? limit, bool condition = false]) {
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
      final List<TextSpan> listOfTextSpans = [];
      bool loopBreak = false;

      for (String val in sentences) {
        if (condition && _readMore) {
          if (widget.trimMode == TrimMode.line && val.length > limit!) {
            val = val.substring(0, limit);
            loopBreak = true;
          }

          if (widget.trimMode == TrimMode.length && val.length > limit!) {
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
                style: widget.urlTextStyle ??
                    effectiveTextStyle!.copyWith(color: kAzureRadianceColor, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (!url.startsWith('http://') && !url.startsWith('https://')) url = 'https://$url';

                    if (widget.onTapLink != null) {
                      widget.onTapLink!.call(url);
                    } else {
                      try {
                        Uri launchUri = Uri.parse(url);
                        launchUrl(launchUri, mode: LaunchMode.externalApplication);
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
      return listOfTextSpans;
    }

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Create a TextSpan with data
        final text = TextSpan(
          style: effectiveTextStyle,
          text: widget.data,
        );

        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        // Layout and measure delimiter
        textPainter.text = delimiter;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        int endIndex;

        if (linkSize.width < maxWidth) {
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = textPainter.getPositionForOffset(Offset(
            textDirection == TextDirection.rtl ? readMoreSize : textSize.width - readMoreSize,
            textSize.height,
          ));
          endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
        } else {
          final pos = textPainter.getPositionForOffset(
            textSize.bottomLeft(Offset.zero),
          );
          endIndex = pos.offset;
        }

        ///The code below are the ones which are responsible for the ui of this widget
        InlineSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.length:

            ///Condition which determines whether the given text should be trimmed
            if (widget.trimLength < widget.data.length) {
              final bool con = widget.trimLength < widget.data.length;

              ///Variable created to access the list of the textSpans
              final List<TextSpan> textSpanList = getSentenceList(widget.data, widget.trimLength, con);
              textSpanList.addAll(<TextSpan>[delimiter, link]);
              textSpan = TextSpan(children: textSpanList);
            } else {
              ///Variable created to access the list of the textSpans
              final List<TextSpan> textSpanList = getSentenceList(widget.data);
              textSpan = TextSpan(children: textSpanList);
            }
            break;

          case TrimMode.line:

            ///Condition which determines whether the given text should be trimmed or not
            if (textPainter.didExceedMaxLines) {
              ///Variable created to access the list of the textSpans
              final List<TextSpan> textSpanList = getSentenceList(widget.data, endIndex, textPainter.didExceedMaxLines);
              textSpanList.addAll(<TextSpan>[delimiter, link]);
              textSpan = TextSpan(children: textSpanList);
            } else {
              ///Variable created to access the list of the textSpans
              final List<TextSpan> textSpanList = getSentenceList(widget.data);
              textSpan = TextSpan(children: textSpanList);
            }
            break;
          default:
            throw Exception('TrimMode type: ${widget.trimMode} is not supported');
        }

        return RichText(
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          //softWrap,
          overflow: TextOverflow.clip,
          //overflow,
          textScaleFactor: textScaleFactor,
          text: textSpan,
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(
          child: result,
        ),
      );
    }

    return result;
  }
}
