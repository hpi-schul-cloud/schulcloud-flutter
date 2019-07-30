import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:schulcloud/courses/entities.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LessonScreen extends StatelessWidget {
  final Course course;
  final Lesson lesson;
  String htmlSource;
  WebViewController _controller;

  LessonScreen({this.course, this.lesson})
      : htmlSource = lesson.contents.values.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Column(
          children: <Widget>[
            Text(lesson.name, style: TextStyle(color: Colors.black)),
            Text(course.name, style: TextStyle(color: Colors.black)),
          ],
        ),
        backgroundColor: course.color,
      ),
      bottomNavigationBar: MyAppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.web, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return BottomSheet(
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: lesson.contents.keys
                              .map((name) => NavigationItem(
                                    iconBuilder: (color) => Icon(Icons.textsms),
                                    text: name,
                                    onPressed: () {
                                      if (_controller == null) return null;
                                      htmlSource = lesson.contents[name];
                                      _controller.loadUrl(
                                          _createBase64Source(htmlSource));
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
            },
          )
        ],
      ),
      body: WebView(
        initialUrl: _createBase64Source(htmlSource),
        onWebViewCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }

  String _createBase64Source(String html) {
    var encoded = base64Encode(const Utf8Encoder().convert(html));
    return 'data:text/html;base64,$encoded';
  }
}
