import 'package:flutter/foundation.dart';

class EmptyStateLicense implements LicenseEntry {
  @override
  Iterable<String> get packages => ['empty_state'];

  @override
  Iterable<LicenseParagraph> get paragraphs {
    return [
      LicenseParagraph(
        'Image "empty_state" (shown on empty screens) by Alexey is licensed '
        'under CC BY 4.0.',
        0,
      ),
      LicenseParagraph(
        'For more information about the author Alexey, see '
        'https://www.2dimensions.com/a/rablex',
        1,
      ),
      LicenseParagraph(
        'For CC BY 4.0, see https://creativecommons.org/licenses/by/4.0.',
        1,
      ),
    ];
  }
}
