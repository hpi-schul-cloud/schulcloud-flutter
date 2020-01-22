import 'package:flutter/widgets.dart' show BuildContext;

import 'l10n.dart';
export 'l10n.dart';

extension Localization on BuildContext {
  S get s => S.of(this);
}
