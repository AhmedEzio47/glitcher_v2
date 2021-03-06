import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:glitcher/services/route_generator.dart';

class UrlText extends StatelessWidget {
  final BuildContext context;
  final String text;
  final TextStyle style;
  final TextStyle urlStyle;
  final Future Function(String) onHashTagPressed;
  final Future Function(String) onMentionPressed;

  UrlText(
      {this.text,
      this.style,
      this.urlStyle,
      this.onHashTagPressed,
      this.onMentionPressed,
      this.context});

  List<InlineSpan> getTextSpans() {
    List<InlineSpan> widgets = List<InlineSpan>();
    RegExp reg = RegExp(
        r"([#])\w+|([@])\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text);
    List<_ResultMatch> resultMatches = List<_ResultMatch>();
    int start = 0;
    for (Match match in _matches) {
      if (match.group(0).isNotEmpty) {
        if (start != match.start) {
          _ResultMatch result1 = _ResultMatch();
          result1.isUrl = false;
          result1.text = text.substring(start, match.start);
          resultMatches.add(result1);
        }

        _ResultMatch result2 = _ResultMatch();
        result2.isUrl = true;
        result2.text = match.group(0);
        resultMatches.add(result2);
        start = match.end;
      }
    }
    if (start < text.length) {
      _ResultMatch result1 = _ResultMatch();
      result1.isUrl = false;
      result1.text = text.substring(start);
      resultMatches.add(result1);
    }
    for (var result in resultMatches) {
      if (result.isUrl) {
        widgets.add(_LinkTextSpan(
            context: this.context,
            onHashTagPressed: onHashTagPressed,
            onMentionPressed: onMentionPressed,
            text: result.text,
            style:
                urlStyle != null ? urlStyle : TextStyle(color: Colors.blue)));
      } else {
        widgets.add(TextSpan(
            text: result.text,
            style: style != null ? style : TextStyle(color: Colors.black)));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: getTextSpans()),
    );
  }
}

class _LinkTextSpan extends TextSpan {
  final BuildContext context;
  final Future Function(String) onHashTagPressed;
  final Future Function(String) onMentionPressed;

  _LinkTextSpan(
      {this.context,
      TextStyle style,
      String text,
      this.onHashTagPressed,
      this.onMentionPressed})
      : super(
            style: style,
            text: text,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onHashTagPressed != null &&
                    (text.contains("#") || text.contains("#"))) {
                  onHashTagPressed(text);
                } else if (onMentionPressed != null &&
                    (text.contains("@") || text.contains("@"))) {
                  onMentionPressed(text);
                } else {
                  //print('text is $text');
                  Navigator.of(context)
                      .pushNamed(RouteList.browser, arguments: {
                    'url': text,
                  });
                }
              });
}

class _ResultMatch {
  bool isUrl;
  String text;
}
