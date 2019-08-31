import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/courses/data/content.dart';
import 'package:schulcloud/courses/entities.dart';

class LessonScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;

  LessonScreen({this.course, this.lesson});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Column(
          children: <Widget>[
            Text(widget.lesson.name, style: TextStyle(color: Colors.black)),
            Text(widget.course.name, style: TextStyle(color: Colors.black)),
          ],
        ),
        backgroundColor: widget.course.color,
      ),
      bottomNavigationBar: MyAppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.web),
            onPressed: () => _showLessonContentMenu(context: context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WebView(
          initialUrl: _textOrUrl(widget.lesson.contents[0]),
          onWebViewCreated: (controller) => _controller = controller,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }

  String _createBase64Source(String html) {
    var encoded = base64Encode(const Utf8Encoder().convert(html));
    return 'data:text/html;base64,$encoded';
  }

  String _textOrUrl(Content content) {
    if (content.isText) {
      return _createBase64Source(content.text);
    } else if (!content.isTypeKnown) {
      return _createBase64Source('<p>Dieser Datentyp ist unbekannt</p>');
    } else {
      return content.url;
    }
  }

  void _showLessonContentMenu({BuildContext context}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.lesson.contents
                    .map((content) => NavigationItem(
                          iconBuilder: (color) => Icon(Icons.textsms),
                          text: content.title,
                          onPressed: () {
                            if (_controller == null) return null;
                            _controller.loadUrl(_textOrUrl(content));
                            Navigator.pop(context);
                          },
                          isActive: false,
                        ))
                    .toList(),
              );
            },
            onClosing: () {},
          );
        });
  }
}
