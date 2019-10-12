import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FileBrowserAppBar extends StatefulWidget {
  const FileBrowserAppBar({this.backgroundColor, this.title});

  final Color backgroundColor;
  final String title;

  @override
  _FileBrowserAppBarState createState() => _FileBrowserAppBarState();
}

class _FileBrowserAppBarState extends State<FileBrowserAppBar> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: Navigator.of(context),
      transitionOnUserGestures: true,
      flightShuttleBuilder: _buildFlightShuttle,
      child: AppBar(
        key: ValueKey<String>(widget.title),
        backgroundColor: widget.backgroundColor,
        title: Text(widget.title, style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  String titleFromHeroContext(BuildContext context) =>
      (((context.widget as Hero).child as AppBar).key as ValueKey<String>)
          .value;

  Widget _buildFlightShuttle(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    String fromTitle = titleFromHeroContext(fromContext);
    String toTitle = titleFromHeroContext(toContext);

    return AppBar(
      backgroundColor: widget.backgroundColor,
      leading: BackButton(color: Colors.black),
      title: AnimatedTitle(
        parentTitle:
            direction == HeroFlightDirection.push ? fromTitle : toTitle,
        childTitle: direction == HeroFlightDirection.push ? toTitle : fromTitle,
        animation: animation,
      ),
    );
  }
}

class AnimatedTitle extends StatefulWidget {
  final String parentTitle;
  final String childTitle;
  final Animation<double> animation;

  AnimatedTitle({
    @required this.parentTitle,
    @required this.childTitle,
    @required this.animation,
  })  : assert(parentTitle != null),
        assert(childTitle != null),
        assert(animation != null);

  @override
  _AnimatedTitleState createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> {
  Widget parentTitle;
  Widget childTitle;

  @override
  void initState() {
    super.initState();
    void listener() {
      if (mounted) {
        setState(() {
          // Rebuild widget with new animation value.
        });
      } else {
        widget.animation.removeListener(listener);
      }
    }

    widget.animation.addListener(listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parentTitle =
        Text(widget.parentTitle, style: TextStyle(color: Colors.black));
    childTitle = Text(widget.childTitle, style: TextStyle(color: Colors.black));
  }

  double get animValue => widget.animation.value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset(-20.0 * animValue, 0),
          child: Opacity(
            opacity: (1 - 2 * animValue).clamp(0.0, 1.0),
            child: parentTitle,
          ),
        ),
        Transform.translate(
          offset: Offset(20 * (1 - animValue), 0),
          child: Opacity(
            opacity: (2 * animValue - 1).clamp(0.0, 1.0),
            child: childTitle,
          ),
        )
      ],
    );
  }
}
