import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/theming/utils.dart';
import 'package:sprintf/sprintf.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({@required this.course, @required this.lesson})
      : assert(course != null),
        assert(lesson != null);

  final Course course;
  final Lesson lesson;

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

  void _showLessonContentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => BottomSheet(
        builder: (_) => _buildBottomSheetContent(),
        onClosing: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Column(
          children: <Widget>[
            Text(
              widget.lesson.name,
              style: TextStyle(color: Colors.black),
            ),
            Text(
              widget.course.name,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        backgroundColor: widget.course.color,
      ),
      body: AppBarActions(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.web),
            onPressed: _showLessonContentMenu,
          ),
        ],
        child: Padding(
          padding: EdgeInsets.all(8),
          child: WebView(
            initialUrl: _textOrUrl(widget.lesson.contents[0]),
            onWebViewCreated: (controller) => _controller = controller,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }

  String _createTextSource(String html) {
    final theme = Theme.of(context);

    String cssColor(Color color) {
      return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})';
    }

    final fullHtml = sprintf(
      contentTextFormat,
      [
        html,
        AppConfig.of(context).host,
        cssColor(highEmphasisOnBrightness(theme.brightness)),
        cssColor(theme.accentColor),
      ],
    );
    return Uri.dataFromString(
      fullHtml,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();
  }

  String _textOrUrl(Content content) =>
      content.isText ? _createTextSource(content.text) : content.url;

  Widget _buildBottomSheetContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var content in widget.lesson.contents)
          NavigationItem(
            icon: Icons.textsms,
            text: content.title,
            onPressed: () {
              if (_controller == null) {
                return;
              }
              _controller.loadUrl(_textOrUrl(content));
              Navigator.pop(context);
            },
            isActive: false,
          ),
      ],
    );
  }
}
