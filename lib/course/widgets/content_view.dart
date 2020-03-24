import 'dart:math';

import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:schulcloud/app/app.dart';

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

  final Component component;

  @override
  Widget build(BuildContext context) {
    // Required so Dart automatically casts component in if-branches.
    final component = this.component;
    if (component is TextComponent) {
      if (component.text == null) {
        return SizedBox();
      }
      return FancyText.rich(component.text);
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
    if (component is ResourcesComponent) {
      return Column(
        children: <Widget>[
          for (final resource in component.resources) ...[
            // Space before the first card is intended as that's the only
            // spacing between the first card and the content's title.
            SizedBox(height: 16),
            _ResourceCard(resource),
          ],
        ],
      );
    }

    assert(component is UnsupportedComponent);
    return EmptyStateScreen(text: context.s.course_contentView_unsupported);
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard(this.resource) : assert(resource != null);

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      omitHorizontalPadding: true,
      omitBottomPadding: true,
      onTap: () => tryLaunchingUrl(resource.url),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildContent(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  resource.title,
                  style: context.textTheme.subhead,
                ),
              ),
              Icon(Icons.open_in_new),
            ],
          ),
          if (resource.description != null) ...[
            SizedBox(height: 4),
            FancyText.preview(
              resource.description,
              maxLines: null,
              textType: TextType.plain,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
        color: theme.disabledOnBackground,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FancyText(
        'via ${resource.client}',
        emphasis: TextEmphasis.medium,
      ),
    );
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
              label: Text(context.s.general_viewInBrowser),
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
