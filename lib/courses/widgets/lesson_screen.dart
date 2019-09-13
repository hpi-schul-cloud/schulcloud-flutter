import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:schulcloud/app/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data.dart';

class LessonScreen extends StatefulWidget {
  final Course course;
  final Lesson lesson;

  LessonScreen({this.course, this.lesson});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
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
            onPressed: () => _showLessonContentMenu(),
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
    return content.isText ? _createBase64Source(content.text) : content.url;
  }

  Widget _buildBottomSheetContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.lesson.contents
          .map((content) => _buildBottomSheetItem(content))
          .toList(),
    );
  }

  Widget _buildBottomSheetItem(Content content) {
    return NavigationItem(
      iconBuilder: (color) => Icon(Icons.textsms),
      text: content.title,
      onPressed: () {
        if (_controller == null) return;
        _controller.loadUrl(_textOrUrl(content));
        Navigator.pop(context);
      },
      isActive: false,
    );
  }
}
