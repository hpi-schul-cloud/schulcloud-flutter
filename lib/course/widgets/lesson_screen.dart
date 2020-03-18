import 'dart:convert';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:sprintf/sprintf.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({@required this.courseId, @required this.lessonId})
      : assert(courseId != null),
        assert(lessonId != null);

  final Id<Course> courseId;
  final Id<Lesson> lessonId;

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  static const contentTextFormat = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <base href="%1\$s" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * {
            max-width: 100%%;
            word-wrap: break-word;
        }
        body {
            margin: 0;
            font-family: 'Roboto', sans-serif;
            color: %2\$s;
        }
        body a {
            color: %3\$s;
            text-decoration: none;
        }
        body > :first-child {
            margin-top: 0;
        }
        body > :nth-last-child(2) {
            margin-bottom: 0;
        }
        table {
            table-layout: fixed;
            width: 100%%;
        }
        ul {
            -webkit-padding-start: 25px;
        }
    </style>
</head>
<body>
    %0\$s
    <script>
    for (tag of document.body.getElementsByTagName('*')) {
        tag.style.width = '';
        tag.style.height = '';
    }
</script>
</body>
</html>''';

  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return FancyCachedBuilder<Lesson>.handleLoading(
      controller: widget.lessonId.controller,
      builder: (context, lesson, isFetching) {
        return FancyScaffold(
          appBar: FancyAppBar(
            title: Text(lesson.name),
            subtitle: CachedRawBuilder<Course>(
              controller: widget.courseId.controller,
              builder: (_, update) {
                final course = update.data;
                return Text(course?.name ?? context.s.general_loading);
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.web),
                onPressed: () => _showLessonContentMenu(context, lesson),
              ),
            ],
          ),
          sliver: SliverFillRemaining(
            child: WebView(
              initialUrl: _buildWebViewUrl(lesson.contents[0]),
              onWebViewCreated: (controller) => _controller = controller,
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        );
      },
    );
  }

  void _showLessonContentMenu(BuildContext context, Lesson lesson) {
    context.showFancyModalBottomSheet(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final content in lesson.contents)
            NavigationItem(
              icon: Icons.textsms,
              text: content.title,
              onPressed: () {
                if (_controller == null) {
                  return;
                }
                _controller.loadUrl(_buildWebViewUrl(content));
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  String _buildWebViewUrl(Content content) =>
      content.isText ? _createTextSource(content.text) : content.url;
  String _createTextSource(String html) {
    final theme = context.theme;

    String cssColor(Color color) =>
        'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})';

    final fullHtml = sprintf(
      contentTextFormat,
      [
        html,
        services.config.baseWebUrl,
        cssColor(theme.contrastColor),
        cssColor(theme.accentColor),
      ],
    );
    return Uri.dataFromString(
      fullHtml,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();
  }
}
