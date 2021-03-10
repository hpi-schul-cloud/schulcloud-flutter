import 'package:dartx/dartx.dart';

extension FancyString on String? {
  // ignore: unnecessary_this
  String? get emptyToNull => this?.isEmpty != false ? null : this;
  // ignore: unnecessary_this
  String? get blankToNull => this?.isBlank != false ? null : this;
}
