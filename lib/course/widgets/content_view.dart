import 'dart:math';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:schulcloud/app/app.dart';
import 'package:sprintf/sprintf.dart';

import '../data.dart';

class ContentView extends StatelessWidget {
  const ContentView(this.content, {Key key})
      : assert(content != null),
        super(key: key);

  final Content content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (content.title != null)
          Text(content.title, style: context.textTheme.headline),
        _ComponentView(content.component),
      ],
    );
  }
}

class _ComponentView extends StatelessWidget {
  const _ComponentView(this.component, {Key key})
      : assert(component != null),
        super(key: key);

  static const _contentTextFormat = '''
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

  final Component component;

  @override
  Widget build(BuildContext context) {
    // Required so dart automatically casts component in if-branches.
    final component = this.component;
    if (component is TextComponent) {
      return FancyText.rich(
        _wrapTextContent(context, component.text),
      );
    }
    if (component is EtherpadComponent) {
      return _ExternalContentWebView(component.url);
    }

    assert(component is UnsupportedComponent);
    return EmptyStateScreen(
      text: 'This content is not yet supported in this app',
    );
  }

  static String _wrapTextContent(BuildContext context, String html) {
    final theme = context.theme;

    String cssColor(Color color) =>
        'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})';

    return sprintf(_contentTextFormat, [
      html,
      services.config.baseWebUrl,
      cssColor(theme.contrastColor),
      cssColor(theme.accentColor),
    ]);
  }
}

class _ExternalContentWebView extends StatelessWidget {
  const _ExternalContentWebView(this.url, {Key key})
      : assert(url != null),
        super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    // About 75 % of the device height minus AppBar and BottomNavigationBar.
    final height = (context.mediaQuery.size.height - 2 * 64) * 0.75;
    return LimitedBox(
      maxHeight: max(384, height),
      child: InAppWebView(
        initialUrl: url,
        initialOptions: InAppWebViewWidgetOptions(
          inAppWebViewOptions: InAppWebViewOptions(transparentBackground: true),
        ),
      ),
    );
  }
}
