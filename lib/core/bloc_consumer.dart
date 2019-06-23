import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

mixin BlocConsumer<T, W extends StatefulWidget> on State<W> {
  T get bloc => Provider.of<T>(context);
}
