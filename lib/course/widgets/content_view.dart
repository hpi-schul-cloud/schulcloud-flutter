import 'dart:math';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
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
      return _ComponentWrapper(
        description: component.description,
        url: component.url,
        child: _ExternalContentWebView(component.url),
      );
    }
    if (component is NexboardComponent) {
      return CachedRawBuilder<User>(
        controller: services.storage.userId.controller,
        builder: (context, update) {
          if (update.hasError) {
            return ErrorBanner(update.error, update.stackTrace);
          } else if (update.hasNoData) {
            return Center(child: CircularProgressIndicator());
          }

          final user = update.data;
          // https://github.com/schul-cloud/schulcloud-client/blob/90e7d1f70be4b0e8224f9e18525a7ef1c7ff297a/views/topic/components/content-neXboard.hbs#L3-L4
          final url =
              '${component.url}?disableConference=true&username=${user.avatarInitials}';
          return _ComponentWrapper(
            description: component.description,
            url: url,
            child: _ExternalContentWebView(url),
          );
        },
      );
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

class _ComponentWrapper extends StatelessWidget {
  const _ComponentWrapper({
    Key key,
    this.description,
    @required this.child,
    this.url,
  })  : assert(child != null),
        super(key: key);

  final String description;
  final Widget child;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (description != null) ...[
          FancyText(description, emphasis: TextEmphasis.medium),
          SizedBox(height: 8),
        ],
        child,
        if (url != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FlatButton.icon(
              textColor: context.theme.mediumEmphasisOnBackground,
              onPressed: () => tryLaunchingUrl(url),
              icon: Icon(Icons.open_in_new),
              label: Text('Open in browser'),
            ),
          ),
      ],
    );
  }
}

class _ExternalContentWebView extends StatefulWidget {
  const _ExternalContentWebView(this.url, {Key key})
      : assert(url != null),
        super(key: key);

  final String url;

  @override
  _ExternalContentWebViewState createState() => _ExternalContentWebViewState();
}

class _ExternalContentWebViewState extends State<_ExternalContentWebView>
    with AutomaticKeepAliveClientMixin {
  // We want WebViews to keep their state after scrolling, so e.g. an Etherpad
  // doesn't have to reload.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // About 75 % of the device height minus AppBar and BottomNavigationBar.
    final webViewHeight = (context.mediaQuery.size.height - 2 * 64) * 0.75;
    return LimitedBox(
      maxHeight: max(384, webViewHeight),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: context.theme.primaryColor),
        ),
        // To make the border visible.
        padding: EdgeInsets.all(1),
        child: InAppWebView(
          initialUrl: widget.url,
          initialOptions: InAppWebViewWidgetOptions(
            inAppWebViewOptions:
                InAppWebViewOptions(transparentBackground: true),
          ),
        ),
      ),
    );
  }
}
