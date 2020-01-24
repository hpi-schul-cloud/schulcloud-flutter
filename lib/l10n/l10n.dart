import 'package:flutter/widgets.dart';
import 'package:schulcloud/generated/l10n.dart';

export 'package:schulcloud/generated/l10n.dart';

extension Localization on BuildContext {
  S get s => S.of(this);
}
