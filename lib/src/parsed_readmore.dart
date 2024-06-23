import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:parsed_readmore/parsed_readmore.dart';



class ParsedReadMore extends StatefulWidget {
  const ParsedReadMore(
    this.parser, {
    Key? key,
    this.colorClickableText,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaleFactor,
    this.semanticsLabel,
    this.callback,
    this.suffixText,
    this.readLessTextStyle,
    this.readMoreTextStyle,
    this.readMoreDelimiterStyle,
    this.readLessDelimiterStyle,
    this.suffixTextStyle,
    this.readLessText = ' show less',
    this.readMoreText = ' read more',
    this.readMoreDelimiter = _kEllipsis,
    this.readLessDelimiter = ' ',
  }) : super(key: key);

  /// Called when state change between [ReadMoreState.expanded] and [ReadMoreState.collapsed]
  final void Function(ReadMoreState oldState, ReadMoreState newstate)? callback;

  /// Text is displayed when the state is [ReadMoreState.collapsed]
  final String readMoreText;

  /// Text is displayed when the state is [ReadMoreState.expanded]
  final String readLessText;

  /// Text is displayed between the trimmed text and [readMoreTextStyle]
  final String readMoreDelimiter;

  /// Text is displayed between the text and [readLessTextStyle]
  final String readLessDelimiter;

  /// Text is displayed if passed irrespective of state and it is appended at the end
  /// of the Text widget.
  final String? suffixText;

  /// TextStyle for [readMoreText]
  final TextStyle? readMoreTextStyle;

  /// TextStyle for [readLessText]
  final TextStyle? readLessTextStyle;

  /// TextStyle for [readMoreDelimiter]
  final TextStyle? readMoreDelimiterStyle;

  /// TextStyle for [readLessDelimiter]
  final TextStyle? readLessDelimiterStyle;

  /// TextStyle for [suffixText]
  final TextStyle? suffixTextStyle;

  final TextHighlightParser parser;
  final Color? colorClickableText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final double? textScaleFactor;
  final String? semanticsLabel;

  @override
  ParsedReadMoreState createState() => ParsedReadMoreState();
}

const String _kEllipsis = '\u2026';

class ParsedReadMoreState extends State<ParsedReadMore> {
  late final Iterable<TextRange> _allUrlRanges;
  late final List<TextHighlight> _allTextHighlights;
  // Below variables key refers to each character position in the text, which
  // needs to be highlighted. After `findTextHighlights` is called. Simply put,
  // below Map is created for faster access, to Priority Target Text Highlights
  // Style, else we would have needed to loop over all Text Highlights.
  late final Map<int, TargetTextHighlights> _allIndexTargetTextHighlightsMap;
  late final List<TapGestureRecognizer> _assignedTapGestureRecognizers;
  late ReadMoreState _readMoreState;

  @override
  void initState() {
    super.initState();
    _assignedTapGestureRecognizers = [];
    _readMoreState = ReadMoreState.collapsed;
    _allUrlRanges = widget.parser.findUrlRanges();
    _allTextHighlights = widget.parser.findTextHighlights();
    _allIndexTargetTextHighlightsMap =
        TextHighlightParser.createIndexTargetTextHighlightsMap(
      _allTextHighlights,
    );
  }

  @override
  void dispose() {
    for (final tap in _assignedTapGestureRecognizers) {
      tap.dispose();
    }
    super.dispose();
  }

  void _trackActiveTapGesture(TapGestureRecognizer tap) {
    _assignedTapGestureRecognizers.add(tap);
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle =
        widget.style ?? const TextStyle(color: Colors.black);
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    var textScaleFactor = MediaQuery.textScalerOf(context);
    if (widget.textScaleFactor != null) {
      textScaleFactor = TextScaler.linear(widget.textScaleFactor!);
    }
    final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    final colorClickableText =
        widget.colorClickableText ?? Theme.of(context).colorScheme.secondary;
    final defaultReadLessStyle = widget.readLessTextStyle ??
        effectiveTextStyle.copyWith(color: colorClickableText);
    final defaultReadMoreStyle = widget.readMoreTextStyle ??
        effectiveTextStyle.copyWith(color: colorClickableText);
    final defaultReadMoreDelimiterStyle =
        widget.readMoreDelimiterStyle ?? defaultReadMoreStyle;
    final defaultReadLessDelimiterStyle =
        widget.readLessDelimiterStyle ?? defaultReadLessStyle;
    final suffixStyle = widget.suffixTextStyle ?? effectiveTextStyle;

    final isCollapsedState = _readMoreState == ReadMoreState.collapsed;

    final expandCollapseTextSpan = TextSpan(
      text: isCollapsedState ? widget.readMoreText : widget.readLessText,
      style: isCollapsedState ? defaultReadMoreStyle : defaultReadLessStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapExpandCollapseText,
    );

    final readMoreDelimiterTextSpan = TextSpan(
      text: isCollapsedState ? widget.readMoreDelimiter : null,
      style: defaultReadMoreDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapExpandCollapseText,
    );

    final readLessDelimiterTextSpan = TextSpan(
      text: isCollapsedState ? null : widget.readLessDelimiter,
      style: defaultReadLessDelimiterStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapExpandCollapseText,
    );

    final suffixTextSpan = TextSpan(
      text: widget.suffixText,
      style: suffixStyle,
    );

    // Create a TextSpan with data
    final dataTextSpan = TextSpan(
      style: effectiveTextStyle,
      text: widget.parser.data,
    );

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);

        // Layout and measure link
        final textPainter = TextPainter(
          textAlign: textAlign,
          textDirection: textDirection,
          textScaler: textScaleFactor,
          maxLines: widget.parser.trimMode == TrimMode.line && isCollapsedState
              ? widget.parser.maxLines
              : null,
          ellipsis: overflow == TextOverflow.ellipsis
              ? widget.readMoreDelimiter
              : null,
          locale: locale,
        );

        final maxShowCharactersLength = widget.parser.maxCharactersToShow(
          dataTextSpan: dataTextSpan,
          constraints: constraints,
          textPainter: textPainter,
          suffixTextSpan: suffixTextSpan,
          expandCollapseTextSpan: expandCollapseTextSpan,
          readMoreDelimiterTextSpan: readMoreDelimiterTextSpan,
          readLessDelimiterTextSpan: readLessDelimiterTextSpan,
          readMoreState: _readMoreState,
        );

        final textSpanList = <TextSpan>[
          ...widget.parser.getSentenceList(
            maxShowCharactersLength: maxShowCharactersLength,
            effectiveTextStyle: effectiveTextStyle,
            allTextHighlights: _allTextHighlights,
            allUrlRanges: _allUrlRanges,
            allIndexTargetTextHighlightsMap: _allIndexTargetTextHighlightsMap,
            trackActiveTapGesture: _trackActiveTapGesture,
          ),
        ];

        if (widget.parser.shouldEnableExpandCollapse) {
          final isShowingAll =
              maxShowCharactersLength >= widget.parser.data.length;
          // Below we have to do that because the initial value of
          // _readMoreState is set to [ReadMoreState.collapsed] during the
          // init method call. And we can't seems to find a way to get set
          // the value of _readMoreState before first frame build. As to compute
          // [_readMoreState] it need available layout and measure result.
          if (widget.parser.trimMode == TrimMode.none &&
              isCollapsedState &&
              isShowingAll) {
            SchedulerBinding.instance.addPostFrameCallback(
              (_) => _onTapExpandCollapseText(),
            );
          } else if (isCollapsedState) {
            textSpanList.addAll(
              [
                readMoreDelimiterTextSpan,
                expandCollapseTextSpan,
              ],
            );
          } else {
            textSpanList.addAll(
              [
                readLessDelimiterTextSpan,
                expandCollapseTextSpan,
              ],
            );
          }
        }

        textSpanList.add(suffixTextSpan);

        return RichText(
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          overflow: TextOverflow.clip,
          textScaler: textScaleFactor,
          text: TextSpan(children: textSpanList),
        );
      },
    );
    if (widget.semanticsLabel != null) {
      result = Semantics(
        textDirection: widget.textDirection,
        label: widget.semanticsLabel,
        child: ExcludeSemantics(child: result),
      );
    }

    return result;
  }

  void _onTapExpandCollapseText() {
    if (!widget.parser.shouldEnableExpandCollapse) {
      return;
    }

    final currentState = _readMoreState;
    final isExpanded = currentState == ReadMoreState.expanded;
    final isCollapsed = currentState == ReadMoreState.collapsed;

    if (isExpanded) {
      _readMoreState = ReadMoreState.collapsed;
    }

    if (isCollapsed) {
      _readMoreState = ReadMoreState.expanded;
    }

    setState(() {
      widget.callback?.call(currentState, _readMoreState);
    });
  }
}
