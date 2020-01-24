import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import 'menu.dart';
import 'schulcloud_app.dart';

final _appBarKey = GlobalKey();

/// A custom version of an app bar intended to be displayed at the bottom of
/// the screen. You can also also call [_MyAppBarState.register] and
/// [_MyAppBarState.unregister] to register and unregister actions on the app
/// bar. The [AppBarActions] does that.
class MyAppBar extends StatefulWidget {
  MyAppBar({
    @required this.onNavigate,
    @required this.activeScreenStream,
  })  : assert(onNavigate != null),
        super(key: _appBarKey);

  final void Function(Screen route) onNavigate;
  final Stream<Screen> activeScreenStream;

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  final _actionsByState = <State<AppBarActions>, List<Widget>>{};
  final _actions = <Widget>[];

  void register(State<AppBarActions> state, List<Widget> actions) {
    Future.microtask(() {
      setState(() {
        _actions.addAll(actions);
        _actionsByState[state] = actions;
      });
    });
  }

  void unregister(State<AppBarActions> state) {
    Future.microtask(() {
      setState(() {
        final actionsToRemove = _actionsByState.remove(state);
        _actions.removeWhere(actionsToRemove.contains);
      });
    });
  }

  Future<void> _showMenu(BuildContext context) async {
    final target = await context.navigator.push(PageRouteBuilder(
      pageBuilder: (_, __, ___) =>
          Menu(activeScreenStream: widget.activeScreenStream),
      opaque: false,
      maintainState: true,
      transitionsBuilder: _customDialogTransitionBuilder,
    ));
    if (target != null) {
      widget.onNavigate(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.bottomAppBarColor,
      elevation: 12,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: context.theme.contrastColor),
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _showMenu(context),
              ),
              Spacer(),
              ..._actions,
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that adds actions to the enclosing [MyAppBar].
class AppBarActions extends StatefulWidget {
  const AppBarActions({@required this.actions, @required this.child})
      : assert(actions != null),
        assert(child != null);

  final List<Widget> actions;
  final Widget child;

  @override
  _AppBarActionsState createState() => _AppBarActionsState();
}

class _AppBarActionsState extends State<AppBarActions> {
  _MyAppBarState _findEnclosingMyAppBar() => _appBarKey.currentState;

  @override
  void initState() {
    super.initState();
    _findEnclosingMyAppBar().register(this, widget.actions);
  }

  @override
  void dispose() {
    _findEnclosingMyAppBar().unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Widget _customDialogTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return Stack(
    children: <Widget>[
      FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTap: () => context.navigator.popUntil((route) => route.isFirst),
          child: Container(color: Colors.black45),
        ),
      ),
      SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuad,
        )),
        child: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    ],
  );
}
